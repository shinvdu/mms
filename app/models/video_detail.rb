class VideoDetail < ActiveRecord::Base
  belongs_to :user_video
  belongs_to :transcoding
  has_many :snapshots
  mount_uploader :public_video, PublicVideoUploader if not Rails.env.test? 
  mount_uploader :private_video, PrivateVideoUploader  if not Rails.env.test? 
  scope :transcoded, -> { where(['fragment=false and transcoding_id > 1']) }

  require 'fileutils'
  require 'uuidtools'

  module STATUS
    NONE = 10
    PROCESSING = 20
    ONLY_LOCAL = 30
    ONLY_REMOTE = 40
    BOTH = 50
  end

  include MTSWorker::VideoDetailWorker
  include OSS

  def video
    self.public ? self.public_video : self.private_video
  end

  def video=(param)
    self.public ? self.public_video = param : self.private_video = param
  end

  def store_dir
    return File.dirname(self.uri)
  end

  def public_remote_file_name
    File.basename self.uri if self.uri.present? && self.public
  end

  def private_remote_file_name
    File.basename self.uri if self.uri.present? && !self.public
  end

  def bucket
    self.public ? Settings.aliyun.oss.public_bucket : Settings.aliyun.oss.private_bucket
  end

  def set_video(user_video, video)
    self.user_video = user_video
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.uri = File.join(Settings.aliyun.oss.user_video_dir, self.uuid, "#{self.uuid}#{user_video.ext_name}")
    self.status = STATUS::ONLY_LOCAL

    temp_path = Rails.root.join(Settings.file_server.dir, self.uri)
    dir = File.dirname(temp_path)
    FileUtils.makedirs(dir) if !File.directory?(dir)
    FileUtils.mv(video.path, temp_path)
    self
  end

  def set_ad_video(ad_video, video)
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.uri = File.join(Settings.aliyun.oss.advertise_dir, self.uuid, "#{self.uuid}#{File.extname(video.original_filename)}")
    self.status = STATUS::ONLY_LOCAL

    # TODO save file to file server
    temp_path = Rails.root.join(Settings.file_server.dir, self.uri)
    dir = File.dirname(temp_path)
    FileUtils.makedirs(dir) if !File.directory?(dir)
    FileUtils.mv(video.path, temp_path)
    self
  end

  def set_attributes_by_hash(params)
    params.each do |k, v|
      send "#{k}=", v
    end
    self
  end

  def get_full_path
    Rails.root.join(Settings.file_server.dir, self.uri).to_s
  end

  def get_full_url
    "#{Settings.aliyun.oss.download_proxy}#{self.bucket}.#{Settings.aliyun.oss.host}/#{self.uri}"
  end

  def full_cache_path!
    # BE CAREFUL, move cache file to full_path immediately. It will not be removed automatically
    self.video.cache_stored_file!
    Rails.root.join('public', self.video.cache_dir, self.video.cache_name)
  end

  def create_sub_video(start, stop, suffix)
    start_time = start.to_time
    stop_time = stop.to_time
    input_path = self.get_full_path
    output_path = input_path.split('.').insert(-2, suffix).join('.')
    logger.debug "slice video to #{output_path}"
    slice_video(input_path, output_path, start_time, stop_time)
    sub_video = VideoDetail.new.set_attributes_by_hash(self.copy_attributes)
    sub_video.uri = self.uri.split('.').insert(-2, suffix).join('.')
    File.open(output_path) { |f| sub_video.video = f }
    sub_video.fetch_video_info
    sub_video.status = VideoDetail::STATUS::BOTH
    sub_video.fragment = true
    sub_video.save!
    sub_video
  end

  def create_mp4_video(input_path = nil)
    input_path ||= self.get_full_path
    output_path = self.get_full_path.split('.')[0..-2].append('mp4').join('.')
    if self.user_video.ext_name == '.mp4' && input_path == output_path
      return self
    end
    `ffmpeg  -i #{input_path}  -y -vcodec copy -acodec copy #{output_path}`
    mp4_video = VideoDetail.new.set_attributes_by_hash(self.copy_attributes)
    mp4_video.uri = self.uri.split('.')[0..-2].append('mp4').join('.')
    mp4_video.status = VideoDetail::STATUS::ONLY_LOCAL
    mp4_video.fetch_video_info
    mp4_video
  end

  def create_mkv_video(input_path = nil)
    input_path ||= self.get_full_path
    output_path = self.get_full_path.split('.')[0..-2].append('mkv').join('.')
    if self.user_video.ext_name == '.mkv' && input_path == output_path
      return self
    end
    output_dir = File.dirname output_path
    FileUtils.mkpath output_dir if !File.exist? output_dir
    logger.info "ffmpeg  -i #{input_path}  -y -vcodec copy -acodec copy #{output_path}"
    `ffmpeg  -i #{input_path}  -y -vcodec copy -acodec copy #{output_path}`
    mkv_video = VideoDetail.new.set_attributes_by_hash(self.copy_attributes)
    mkv_video.uri = self.uri.split('.')[0..-2].append('mkv').join('.')
    mkv_video.status = VideoDetail::STATUS::ONLY_LOCAL
    mkv_video.fetch_video_info
    mkv_video
  end

  def copy_attributes
    self.attributes.except('id', 'public_video', 'private_video', 'created_at', 'md5', 'status', 'public')
  end

  def slice_video(input, output, start_time, stop_time)
    logger.debug `ffmpeg -i #{input} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output}`
    `ffmpeg -i #{input} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output}`
  end

  def load_local_file!(path = nil)
    local_path = path || self.get_full_path
    logger.debug "load file: #{path}"
    File.open(local_path) do |file|
      self.video = file
      self.status = local_path == path ? VideoDetail::STATUS::BOTH : STATUS::ONLY_REMOTE
      self.save!
    end
  end

  def load_local_file_if_necessary!(path = nil)
    return if self.REMOTE?
    local_path = path || self.get_full_path
    File.open(local_path) do |file|
      self.video = file
      self.status = local_path == path ? VideoDetail::STATUS::BOTH : STATUS::ONLY_REMOTE
      self.save!
    end
  end

  def load_local_file_to_public!
    new_video = VideoDetail.create.set_attributes_by_hash(self.copy_attributes)
    new_video.public = true
    new_video.md5 = self.md5
    new_video.create_uri_by_id_and_uuid
    new_video.status = VideoDetail::STATUS::ONLY_REMOTE
    new_video.load_local_file! self.get_full_path
    new_video
  end

  def create_uri_by_id_and_uuid
    self.uri = File.join(Settings.aliyun.oss.user_video_dir, self.uuid, "#{self.uuid}.#{self.id}#{user_video.ext_name}")
  end

  def remove_local_file
    logger.info "remove local file[id: %s]: %s" % [self.id, self.get_full_path]
    FileUtils.rm self.get_full_path if File.exist? self.get_full_path
    dir = File.dirname(self.get_full_path)
    FileUtils.rmtree dir if File.exist?(dir) && (Dir.entries(dir) - %w{ . .. }).empty?
    if self.REMOTE?
      self.status = STATUS::ONLY_REMOTE
    else
      self.status = STATUS::NONE
    end
  end

  def remove_local_file!
    remove_local_file
    self.save!
  end

  require 'rubygems'
  require 'streamio-ffmpeg'

  def fetch_video_info
    if !File.exist? self.get_full_path
      logger.warn "fetch video info but not exist: #{self.get_full_path}"
      return
    end
    self.md5 = Digest::MD5.file(self.get_full_path).hexdigest
    movie = FFMPEG::Movie.new(self.get_full_path)
    if movie.valid?
      self.duration = movie.duration
      self.rate = movie.bitrate
      self.size = movie.size
      self.video_codec = movie.video_codec
      self.audio_codec = movie.audio_codec
      self.resolution = movie.resolution
      self.width = movie.width
      self.height = movie.height
      self.format = movie.container
      if user_video.present? && user_video.original_video == self
        user_video.duration = self.duration
        user_video.width = self.width
        user_video.height = self.height
      end
    end
  end

  def self.create_mkv_video_by_fragments(video_fragments)
    uuid = UUIDTools::UUID.random_create.to_s
    new_video = VideoDetail.create(:public => false,
                                   :uuid => uuid,
                                   :uri => File.join(Settings.aliyun.oss.video_product_dir, uuid, "#{uuid}.mkv")
    )
    file_paths = []
    logger.debug video_fragments.inspect
    video_fragments.each_with_index do |frag, idx|
      tmp_path = "tmp/#{uuid}/#{idx}.mkv"
      logger.info "create video fragment in #{tmp_path} [id: #{frag.id}]"
      frag.slice_mkv_video(tmp_path)
      if File.exist? tmp_path
        logger.info 'create fragment succeed'
        file_paths.append tmp_path
      else
        logger.warning 'create fragment fail'
      end
    end
    output_path = new_video.get_full_path
    logger.info "merge video fragments to #{output_path}"
    `mkvmerge  -o #{output_path} #{file_paths.join(' +')}`

    FileUtils.rmtree File.dirname(file_paths.first) if file_paths.present?
    # file_paths.each { |path| FileUtils.rm path }
    new_video.status = VideoDetail::STATUS::ONLY_LOCAL
    new_video.fetch_video_info
    new_video.save!
    new_video
  end

  def copy_video_info_from!(video_detail)
    self.set_attributes_by_hash(video_detail.copy_attributes)
    self.md5 = video_detail.md5
    self.public = false
    self.uri = video_detail.uri.split('.').insert(-2, self.id).join('.')
    self.status = VideoDetail::STATUS::NONE
    self.save!
    self
  end

  def publish_video!(local_path)
    self.public = true
    File.open local_path do |f|
      self.video = f
    end
    self.status = VideoDetail::STATUS::ONLY_REMOTE
    self.save!
  end

  def download!
    file_path = self.get_full_path
    if File.exist? file_path
      self.status = self.REMOTE? ? STATUS::BOTH : STATUS::ONLY_LOCAL
      save!
      return
    end
    FileUtils.mkdir_p File.dirname(file_path) unless File.exist? File.dirname(file_path)
    logger.info "download file[id: %s]: %s" % [self.id, self.get_full_path]
    cache_path = self.full_cache_path!
    logger.debug "cp #{cache_path} #{file_path}"
    FileUtils.cp cache_path, file_path
    # TODO
    # must cp before save, save will remove cached file
    self.status = VideoDetail::STATUS::BOTH
    self.save!
  end

  def create_snapshot(video_product_group, n = nil)
    n ||= Settings.aliyun.mts.snapshot_number
    # create n snapshots from 10% to 90%
    iters = n > 0 ? (0..n).to_a.map { |i| self.duration*0.8/n*i+self.duration*0.1 } : [self.duration * 0.1]
    iters.each_with_index do |time, idx|
      uri = File.join(File.dirname(self.uri), [self.id, idx, Settings.aliyun.mts.snapshot_ext].join('.'))
      snapshot = Snapshot.create(:time => time,
                                 :uri => uri,
                                 :video_detail => self,
                                 :video_product_group => video_product_group)
      snapshot.create_mts_job
    end
  end

  def h264_aac?
    self.video_codec.downcase.index('h264') && self.audio_codec.downcase.index('aac')
  end

  def mts_accept?
    logger.debug "check mts accept. [video detail id: #{self.id}] container: #{self.format} video codec: #{self.video_codec} audio_codec: #{self.audio_codec}"
    Settings.aliyun.mts.accepted_containers.any? { |container| self.format.downcase.index(container) } &&
        Settings.aliyun.mts.accepted_video_codec.any? { |vc| self.video_codec.downcase.index(vc) } &&
        Settings.aliyun.mts.accepted_audio_codec.any? { |ac| self.audio_codec.downcase.index(ac) }
  end

  def fetched_info?
    self.md5.present?
  end

  def ONLY_REMOTE?
    self.status == STATUS::ONLY_REMOTE
  end

  def REMOTE?
    self.status == STATUS::ONLY_REMOTE || self.status == STATUS::BOTH
  end

  def LOCAL?
    File.exist? self.get_full_path
  end

  def PROCESSING?
    self.status == STATUS::PROCESSING
  end

  def NONE?
    self.status == STATUS::NONE
  end

end

#------------------------------------------------------------------------------
# VideoDetail
#
# Name           SQL Type             Null    Default Primary
# +----------------+--------------+------+-----+---------+----------------+
# | id             | int(11)      | NO   | PRI | NULL    | auto_increment |
# | uuid           | varchar(255) | YES  |     | NULL    |                |
# | uri            | varchar(255) | YES  |     | NULL    |                |
# | format         | varchar(255) | YES  |     | NULL    |                |
# | md5            | varchar(255) | YES  |     | NULL    |                |
# | rate           | varchar(255) | YES  |     | NULL    |                |
# | size           | int(11)      | YES  |     | NULL    |                |
# | duration       | float        | YES  |     | NULL    |                |
# | status         | int(11)      | YES  |     | NULL    |                |
# | user_video_id  | int(11)      | YES  |     | NULL    |                |
# | created_at     | datetime     | NO   |     | NULL    |                |
# | updated_at     | datetime     | NO   |     | NULL    |                |
# | width          | int(11)      | YES  |     | NULL    |                |
# | height         | int(11)      | YES  |     | NULL    |                |
# | fps            | int(11)      | YES  |     | NULL    |                |
# | transcoding_id | int(11)      | YES  |     | NULL    |                |
# | fragment       | tinyint(1)   | YES  |     | 0       |                |
# | video_codec    | varchar(255) | YES  |     | NULL    |                |
# | audio_codec    | varchar(255) | YES  |     | NULL    |                |
# | resolution     | varchar(255) | YES  |     | NULL    |                |
# | public         | tinyint(1)   | YES  |     | 0       |                |
# | public_video   | varchar(255) | YES  |     | NULL    |                |
# | private_video  | varchar(255) | YES  |     | NULL    |                |
# +----------------+--------------+------+-----+---------+----------------+
