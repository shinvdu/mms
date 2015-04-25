class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail', :dependent => :destroy
  has_many :video_cut_points
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  belongs_to :original_video, :class_name => 'VideoDetail'
  attr_accessor :STATUS_UPLOADED, :GOT_LOW_RATE

  @@STATUS_UPLOADED = 1
  @@GOT_LOW_RATE = 2

  def initialize(owner, videoName, video)
    super()
    self.owner = owner
    self.video_name = videoName
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    videoDetail = VideoDetail.new(self, video)
    videoDetail.save!
    videoDetail.fetch_video_info_and_upload
    self.original_video = videoDetail
    self.status = @@STATUS_UPLOADED
    # TODO build MTS task and then modify status
    self.status = @@GOT_LOW_RATE
  end

  def GOT_LOW_RATE?
    self.status == @@GOT_LOW_RATE
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
# video_name        varchar(255)         true            false  
# file_name         varchar(255)         true            false  
# ext_name          varchar(255)         true            false  
# duration          int(11)              true            false  
# status            int(11)              true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
