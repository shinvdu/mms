class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail', :dependent => :destroy
  has_many :video_product_groups
  has_many :video_cut_points
  has_many :tags_relationship
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  belongs_to :original_video, :class_name => 'VideoDetail'
  belongs_to :mini_video, :class_name => 'VideoDetail'
  belongs_to :default_transcoding_strategy, :class_name => 'TranscodingStrategy'

  module STATUS
    PREUPLOADED = 10
    UPLOADED = 20
    # GOT_META = 30
    PRETRANSCODING = 40
    GOT_LOW_RATE = 50
    ORIGIN_DELETED = 99
  end

  module STRATEGY
    PACKAGE = 1
    TRANSCODING_AND_PUBLISH = 2
    TRANSCODING_AND_EDIT = 3
  end

  include MTSWorker::UserVideoWorker

  def set_by_video(owner, videoName, video)
    self.owner = owner
    self.video_name = videoName
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    videoDetail = VideoDetail.new.set_video(self, video)
    videoDetail.save!
    self.original_video = videoDetail
    self.status = STATUS::PREUPLOADED
    async_fetch_video_info_and_upload
    self
  end

  def GOT_LOW_RATE?
    self.status == STATUS::GOT_LOW_RATE
  end
end

#------------------------------------------------------------------------------
# UserVideo
#
# Name                            SQL Type             Null    Default Primary
# ------------------------------- -------------------- ------- ------- -------
# id                              int(11)              false           true   
# owner_id                        int(11)              true            false  
# original_video_id               int(11)              true            false  
# mini_video_id                   int(11)              true            false  
# logo_id                         int(11)              true            false  
# video_name                      varchar(255)         true            false  
# file_name                       varchar(255)         true            false  
# ext_name                        varchar(255)         true            false  
# duration                        int(11)              true            false  
# status                          int(11)              true            false  
# created_at                      datetime             false           false  
# updated_at                      datetime             false           false  
# width                           int(11)              true            false  
# height                          int(11)              true            false  
# transcoding_strategy_id         int(11)              true            false  
# default_transcoding_strategy_id int(11)              true            false  
# strategy                        int(11)              true            false  
#
#------------------------------------------------------------------------------
