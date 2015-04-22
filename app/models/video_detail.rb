class VideoDetail < ActiveRecord::Base
  belongs_to :user_video
  mount_uploader :video, VideoUploader

  require 'fileutils'

  def initialize(userVideo, video)
    super()
    self.user_video = userVideo
    self.uuid = UUIDTools::UUID.random_create
    self.uri = File.join('original_video', "#{self.uuid}.#{userVideo.extName}")
    self.video = video

    fetchVideoInfo(video)
  end

  def destroy
    remove_video!
    save
    super
  end

  private

  def fetchVideoInfo(uploadedFile)
    # TODO code here
  end
end

#------------------------------------------------------------------------------
# VideoDetail
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# videoName     varchar(255)         true            false  
# fileName      varchar(255)         true            false  
# extName       varchar(255)         true            false  
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
