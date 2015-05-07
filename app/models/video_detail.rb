class VideoDetail < ActiveRecord::Base
  belongs_to :user_video
  belongs_to :transcoding
  has_many :snapshots
  mount_uploader :public_video, PublicVideoUploader
  mount_uploader :private_video, PrivateVideoUploader
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

  def video
    self.public ? self.public_video : self.private_video
  end

  def video=(param)
    self.public ? self.public_video = param : self.private_video = param
  end

  def store_dir
    return uuid if self.transcoding.nil? || self.fragment || self.transcoding.mini? || self.user_video_id.present?
    return "product_#{self.id}"
  end

  def bucket
    self.public ? Settings.aliyun.oss.public_bucket : Settings.aliyun.oss.private_bucket
  end

  def set_video(user_video, video)
    self.user_video = user_video
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.uri = File.join(Settings.aliyun.oss.user_video_dir, self.uuid, "#{self.uuid}#{user_video.ext_name}")
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
    sub_video.status = VideoDetail::STATUS::BOTH
    sub_video.fragment = true
    sub_video.save!
    sub_video
  end

  def create_mkv_video
    if self.user_video.ext_name == '.mkv'
      return self
    end
    input_path = self.get_full_path
    output_path = self.get_full_path.split('.')[0..-2].append('mkv').join('.')
    `ffmpeg  -i #{input_path}  -y -vcodec copy -acodec copy #{output_path}`
    mkv_video = VideoDetail.new.set_attributes_by_hash(self.copy_attributes)
    mkv_video.uri = self.uri.split('.')[0..-2].append('mkv').join('.')
    mkv_video.status = VideoDetail::STATUS::ONLY_LOCAL
    mkv_video
  end

  def copy_attributes
    self.attributes.except('id', 'public_video', 'private_video', 'created_at', 'md5')
  end

  def slice_video(input, output, start_time, stop_time)
    logger.debug `ffmpeg -i #{input} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output}`
    `ffmpeg -i #{input} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output}`
  end

  def load_local_file!
    File.open(self.get_full_path) do |file|
      self.video = file
      self.status = VideoDetail::STATUS::BOTH
      self.save!
    end
  end

  def remove_local_file!
    FileUtils.rm self.get_full_path if File.exist? self.get_full_path
    if self.REMOTE?
      self.status = STATUS::ONLY_REMOTE
    else
      self.status = STATUS::NONE
    end
    self.save!
  end

  require 'rubygems'
  require 'streamio-ffmpeg'

  def fetch_video_info
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
    end
  end

  def create_mkv_video_by_fragments(video_fragments)
    new_video = VideoDetail.new.set_attributes_by_hash(self.copy_attributes)
    new_video.public = false
    new_video.save!
    new_video.uri = self.uri.split('.').insert(-2, new_video.id).join('.')
    input_path = self.get_full_path
    output_path = new_video.get_full_path

    file_paths = []
    video_fragments.each_with_index do |frag, idx|
      tmp_path = new_video.uri.split('.').insert(-2, idx).join('.')
      file_paths.append tmp_path
      cp = frag.video_cut_point
      time_str = "#{cp.start_time.to_time}-#{cp.stop_time.to_time}"
      `mkvmerge -o #{tmp_path} --split parts:#{time_str} #{input_path}`
    end
    `mkvmerge  -o #{output_path} #{file_paths.join(' +')}`

    file_paths.each_with_index { |path| FileUtils.rm path }
    new_video.save!
    new_video
  end

  def download!
    file_path = self.get_full_path
    cache_path = self.full_cache_path!
    logger.debug "cp #{cache_path} #{file_path}"
    FileUtils.cp cache_path, file_path
    # must cp before save, save will remove cached file
    self.status = VideoDetail::STATUS::BOTH
    self.save!
  end

  def create_snapshot
    n = Settings.aliyun.mts.snapshot_number
    # create n snapshots from 10% to 90%
    (0..n).to_a.map { |i| self.duration*0.8/n*i+self.duration*0.1 }.each_with_index do |time, idx|
      uri = File.join(File.dirname(self.uri), [self.id, idx, Settings.aliyun.mts.snapshot_ext].join('.'))
      snapshot = Snapshot.create(:time => time, :uri => uri, :video_detail => self)
      snapshot.create_mts_job
    end
  end

  def ONLY_REMOTE?
    self.status == STATUS::ONLY_REMOTE
  end

  def REMOTE?
    self.status == STATUS::ONLY_REMOTE || self.status == STATUS::BOTH
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
# -------------- -------------------- ------- ------- -------
# id             int(11)              false           true   
# uuid           varchar(255)         true            false  
# uri            varchar(255)         true            false  
# format         varchar(255)         true            false  
# md5            varchar(255)         true            false  
# rate           varchar(255)         true            false  
# size           int(11)              true            false  
# duration       float                true            false  
# status         int(11)              true            false  
# user_video_id  int(11)              true            false  
# created_at     datetime             false           false  
# updated_at     datetime             false           false  
# video          varchar(255)         true            false  
# width          int(11)              true            false  
# height         int(11)              true            false  
# fps            int(11)              true            false  
# transcoding_id int(11)              true            false  
# fragment       tinyint(1)           true    0       false  
# video_codec    varchar(255)         true            false  
# audio_codec    varchar(255)         true            false  
# resolution     varchar(255)         true            false  
#
#------------------------------------------------------------------------------
