class VideoDetail < ActiveRecord::Base
  belongs_to :user_video
  belongs_to :transcoding
  mount_uploader :video, VideoUploader

  require 'fileutils'
  require 'uuidtools'

  module STATUS
    # NONE = 10
    PROCESSING = 20
    ONLY_LOCAL = 30
    ONLY_REMOTE = 40
    BOTH = 50
  end

  def set_video(user_video, video)
    self.user_video = user_video
    self.uuid = UUIDTools::UUID.random_create
    self.uri = File.join(Settings.aliyun.oss.user_video_dir, self.uuid, "#{self.uuid}#{user_video.ext_name}")
    self.status = STATUS::ONLY_LOCAL

    # TODO save file to file server
    temp_path = Rails.root.join(Settings.file_server.dir, self.uri)
    dir = File.dirname(temp_path)
    FileUtils.makedirs(dir) if !File.directory?(dir)
    FileUtils.mv(video.path, temp_path)
    self
  end

  def get_full_path
    Rails.root.join(Settings.file_server.dir, self.uri).to_s
  end

  def get_full_url
    "#{Settings.aliyun.oss.download_proxy}#{Settings.aliyun.oss.host}/#{self.uri}"
  end

  def create_sub_video(start, stop, suffix)
    start_time = get_time(start)
    stop_time = get_time(stop)
    input_path = self.get_full_path
    output_path = input_path.split('.').insert(-2, suffix).join('.')
    logger.debug "slice video to #{output_path}"
    slice_video(input_path, output_path, start_time, stop_time)
    sub_video = self.dup
    sub_video.uri = self.uri.split('.').insert(-2, suffix).join('.')
    File.open(output_path) { |f| sub_video.video = f }
    sub_video.status = VideoDetail::STATUS::BOTH
    sub_video.fragment = true
    sub_video.save!
    sub_video
  end

  def slice_video(input, output, start_time, stop_time)
    logger.debug `ffmpeg -i #{input} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output}`
    `ffmpeg -i #{input} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output}`
  end

  def get_time(t)
    "#{t.to_i/3600}:#{t.to_i%3600/60}:#{t-t.to_i/60*60}"
  end

  def load_local_file(local_path)
    File.open(local_path) do |file|
      self.video = file
      self.status = VideoDetail::STATUS::BOTH
      self.save!
    end
    self.fetch_video_info
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

  def destroy
    remove_video!
    save
    super
  end

  def ONLY_REMOTE?
    self.status == STATUS::ONLY_REMOTE
  end

  def PROCESSING?
    self.status == STATUS::PROCESSING
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
