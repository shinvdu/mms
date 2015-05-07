class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail', :dependent => :destroy
  has_many :video_product_groups
  has_many :video_cut_points
  has_many :tags_relationship
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  belongs_to :original_video, :class_name => 'VideoDetail'
  belongs_to :mini_video, :class_name => 'VideoDetail'
  belongs_to :mkv_video, :class_name => 'VideoDetail'
  belongs_to :default_transcoding_strategy, :class_name => 'TranscodingStrategy'

  alias_attribute :publish_strategy, :strategy

  module STATUS
    PREUPLOADED = 10
    UPLOADED = 20
    # GOT_META = 30
    PRETRANSCODING = 40
    GOT_LOW_RATE = 50
    BAD_FORMAT_FOR_PACKAGE = 91
    BAD_FORMAT_FOR_MTS = 92
    ORIGIN_DELETED = 99
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
    self.delay.fetch_video_info_and_upload
    self
  end

  def GOT_LOW_RATE?
    self.status == STATUS::GOT_LOW_RATE
  end

  ######################################################
  # asynchronous method
  ######################################################

  def fetch_video_info_and_upload
    video_detail = self.original_video
    video_detail.fetch_video_info
    video_detail.load_local_file!
    if self.publish_strategy == UserVideo::PUBLISH_STRATEGY::PACKAGE &&
        (!video_detail.video_codec.downcase.index('h264') || !video_detail.audio_codec.downcase.index('aac'))
      self.status = UserVideo::STATUS::BAD_FORMAT_FOR_PACKAGE
    end
    # check publish strategy
    # currently only edit
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
      # TODO MTS doesn't support mkv right now
      # middle_template is not created
      logger.debug 'original video is not h264/acc, call mts to transcode'
      transcode_job = create_transcoding_video_job(Transcoding.find_middle_template)
      self.mkv_video = transcode_job.target
    end
    self.save!
  end

  def publish_by_strategy
    case self.publish_strategy
      when PUBLISH_STRATEGY::PACKAGE
        return if self.status == STATUS::BAD_FORMAT_FOR_PACKAGE
        if self.mkv_video.nil? || !self.mkv_video.LOCAL?
          logger.info "mkv video not created, wait for next loop. id: #{self.id}"
          self.delay(run_at: 5.seconds.from_now).publish_by_strategy
          return
        end
        video_product_group = VideoProductGroup.create(:name => self.video_name, :user_video => self)
        video_product_group.create_products_from_mkv
      when PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
        video_product_group = VideoProductGroup.create(:name => self.video_name, :user_video => self, :transcoding_strategy => self.default_transcoding_strategy)
        video_product_group.create_products_from_origin

        #TODO
    end
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
