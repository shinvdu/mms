class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail', :dependent => :destroy
  has_many :video_cut_points
  has_many :tags_relationship
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  belongs_to :original_video, :class_name => 'VideoDetail'
  belongs_to :mini_video, :class_name => 'VideoDetail'

  STATUS_PREUPLOADED = 10
  STATUS_UPLOADED = 20
  # STATUS_GOT_META = 30
  STATUS_GOT_LOW_RATE = 40
  STATUS_PRETRANSCODING = 50
  STATUS_EDITABLE = 60
  STATUS_TRANSCODING = 70

  include MTSWorker::UserVideoWorker

  def initialize(owner, videoName, video)
    super()
    self.owner = owner
    self.video_name = videoName
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    videoDetail = VideoDetail.new(self, video)
    videoDetail.save!
    self.original_video = videoDetail
    self.status = STATUS_PREUPLOADED
    fetch_video_info_and_upload
  end

  def GOT_LOW_RATE?
    self.status == GOT_LOW_RATE
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
# width             int(11)              true            false  
# height            int(11)              true            false  
#
#------------------------------------------------------------------------------
