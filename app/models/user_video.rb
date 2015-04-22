class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail', :dependent => :destroy
  belongs_to :owner, :class_name => 'UserInfo', :foreign_key => :owner_id
  belongs_to :original_video, :class_name => 'VideoDetail'

  def initialize(owner, videoName, video)
    super()
    self.owner = owner
    self.videoName = videoName
    self.fileName = video.original_filename
    self.extName = File.extname(self.fileName)

    videoDetail = VideoDetail.new(self, video)
    self.original_video = videoDetail
    videoDetail.save!

  end
end

#------------------------------------------------------------------------------
# UserVideo
#
# Name              SQL Type             Null    Default Primary
# ----------------- -------------------- ------- ------- -------
# id                int(11)              false           true   
# owner_id          int(11)              true            false  
# original_video_id int(11)              true            false  
# mini_video_id     int(11)              true            false  
# logo_id           int(11)              true            false  
# name              varchar(255)         true            false  
# duration          int(11)              true            false  
# status            int(11)              true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
