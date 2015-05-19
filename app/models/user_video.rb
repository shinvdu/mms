class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail'
  has_many :video_product_groups
  has_many :video_cut_points
  has_many :tags_relationship
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  belongs_to :original_video, :class_name => 'VideoDetail'
  belongs_to :mini_video, :class_name => 'VideoDetail'
  belongs_to :mkv_video, :class_name => 'VideoDetail'
  belongs_to :pre_mkv_video, :class_name => 'VideoDetail'
  belongs_to :default_transcoding_strategy, :class_name => 'TranscodingStrategy'
  validates :video_name, presence: true

  alias_attribute :publish_strategy, :strategy
  attr_accessor :compose_strategy, :players

  module STATUS
    PREUPLOADED = 10
    UPLOADED = 20
    # GOT_META = 30
    PRETRANSCODING = 40
    GOT_LOW_RATE = 50
    ORIGIN_DELETED = 99

  end

  module FORMAT_STATUS
    NORMAL = 0
    BAD_FORMAT_FOR_PACKAGE = 1
    BAD_FORMAT_FOR_MTS = 2
  end

  module PUBLISH_STRATEGY
    PACKAGE = 1
    TRANSCODING_AND_PUBLISH = 2
    TRANSCODING_AND_EDIT = 3
  end

  include MTSWorker::UserVideoWorker

  def set_video(video)
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    video_detail = VideoDetail.new.set_video(self, video)
    video_detail.save!
    self.original_video = video_detail
    self.status = STATUS::PREUPLOADED
    unless self.save
      return self
    end
    self.delay.fetch_video_info_and_upload
    self
  end

  def GOT_LOW_RATE?
    self.status == STATUS::GOT_LOW_RATE
  end

  def EDITABLE?
    [FORMAT_STATUS::NORMAL, FORMAT_STATUS::BAD_FORMAT_FOR_PACKAGE].include? self.format_status
  end

  def status_str
    case self.status
      when (STATUS::PREUPLOADED..STATUS::PRETRANSCODING)
        '处理中'
      when STATUS::GOT_LOW_RATE
        '完成'
      else
        '未知状态'
    end
  end

  ######################################################
  # asynchronous method
  ######################################################

  def fetch_video_info_and_upload
    video_detail = self.original_video
    video_detail.fetch_video_info
    video_detail.load_local_file!
    self.format_status = UserVideo::FORMAT_STATUS::BAD_FORMAT_FOR_PACKAGE if !video_detail.h264_aac?
    self.format_status = UserVideo::FORMAT_STATUS::BAD_FORMAT_FOR_MTS if !video_detail.mts_accept?
    video_detail.create_snapshot(nil, 0)
    create_transcoding_video_job(nil, true)
    create_mkv
    self.status = UserVideo::STATUS::PRETRANSCODING
    self.save!
  end

  def create_mkv
    video_detail = self.original_video
    if video_detail.video_codec.downcase.index('h264') && video_detail.audio_codec.downcase.index('aac')
      logger.debug 'original video is h264/acc, package it locally'
      self.mkv_video = self.original_video.create_mkv_video
    else
      logger.debug 'original video is not h264/acc, call mts to transcode'
      transcode_job = create_transcoding_video_job(Transcoding.find_pre_middle_template)
      transcode_job.post_process_command = "UserVideo.find(#{self.id}).pre_middle_transcode_finished"
      transcode_job.save!
      self.pre_mkv_video = transcode_job.target
    end
    self.save!
  end

  def publish_by_strategy(publish_strategy, transcoding_strategy)
    case publish_strategy
      when PUBLISH_STRATEGY::PACKAGE
        return if self.format_status == FORMAT_STATUS::BAD_FORMAT_FOR_PACKAGE
        self.transaction do
          video_product_group = VideoProductGroup.create(:name => self.video_name, :user_video => self, :owner => self.owner)
          video_product_group.create_package_product
        end
      when PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
        return if self.format_status == FORMAT_STATUS::BAD_FORMAT_FOR_MTS
        self.transaction do
          video_product_group = VideoProductGroup.create(:name => self.video_name, :user_video => self, :owner => self.owner, :transcoding_strategy => transcoding_strategy)
          video_product_group.create_products_from_origin
        end
      when PUBLISH_STRATEGY::TRANSCODING_AND_EDIT
        # nothing to do now
    end
  end

  def pre_middle_transcode_finished
    self.mkv_video = self.pre_mkv_video.create_mkv_video(self.pre_mkv_video.full_cache_path!)
    self.mkv_video.fetch_video_info
    self.mkv_video.save!
    self.pre_mkv_video.remove_local_file
    self.pre_mkv_video.status = VideoDetail::STATUS::NONE
    self.pre_mkv_video.save!
    self.save!
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
# mkv_video_id                    int(11)              true            false  
# format_status                   int(11)              true    0       false  
# pre_mkv_video_id                int(11)              true            false  
#
#------------------------------------------------------------------------------
