class VideoDetail < ActiveRecord::Base
  belongs_to :user_video
  mount_uploader :video, VideoUploader

  require 'fileutils'
  require 'uuidtools'

  def initialize(user_video, video)
    super()
    self.user_video = user_video
    self.uuid = UUIDTools::UUID.random_create
    self.uri = File.join('original_video', self.uuid, "#{self.uuid}#{user_video.ext_name}")

    # TODO save file to file server
    temp_path = Rails.root.join("public/uploads", self.uri)
    dir = File.dirname(temp_path)
    FileUtils.makedirs(dir) if !File.directory?(dir)
    FileUtils.mv(video.path, temp_path)
  end

  def destroy
    remove_video!
    save
    super
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
#
#------------------------------------------------------------------------------
