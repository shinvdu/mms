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

  def initialize(user_video, video)
    super()
    self.user_video = user_video
    self.uuid = UUIDTools::UUID.random_create
    self.uri = File.join(Settings.aliyun.oss.user_video_dir, self.uuid, "#{self.uuid}#{user_video.ext_name}")
    self.status = STATUS::ONLY_LOCAL

    # TODO save file to file server
    temp_path = Rails.root.join(Settings.file_server.dir, self.uri)
    dir = File.dirname(temp_path)
    FileUtils.makedirs(dir) if !File.directory?(dir)
    FileUtils.mv(video.path, temp_path)
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
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# uuid          varchar(255)         true            false  
# uri           varchar(255)         true            false  
# format        varchar(255)         true            false  
# md5           varchar(255)         true            false  
# rate          varchar(255)         true            false  
# size          int(11)              true            false  
# duration      int(11)              true            false  
# status        int(11)              true            false  
# user_video_id int(11)              true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
# video         varchar(255)         true            false  
# width         int(11)              true            false  
# height        int(11)              true            false  
# fps           int(11)              true            false  
#
#------------------------------------------------------------------------------
