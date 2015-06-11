class UserVideo < ActiveRecord::Base
  has_many :videos, :class_name => 'VideoDetail'
  has_many :video_product_groups
  has_many :video_cut_points, :dependent => :delete_all
  has_many :tags_relationships, :dependent => :delete_all
  has_one :video_list_link, :dependent => :delete
  has_one :video_list, :through => :video_list_link
  belongs_to :owner, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  belongs_to :original_video, :class_name => 'VideoDetail', :dependent => :destroy
  belongs_to :mini_video, :class_name => 'VideoDetail', :dependent => :destroy
  belongs_to :mkv_video, :class_name => 'VideoDetail', :dependent => :destroy
  belongs_to :pre_mkv_video, :class_name => 'VideoDetail', :dependent => :destroy
  belongs_to :default_transcoding_strategy, :class_name => 'TranscodingStrategy'
  validates :video_name, presence: true
  include Privilege

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

  def set_video_and_publish(video, publish_strategy, transcoding_strategy)
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    video_detail = VideoDetail.new.set_video(self, video)
    video_detail.save!
    self.original_video = video_detail
    self.status = STATUS::PREUPLOADED
    unless self.save
      return self
    end
    self.delay(:queue => 'local').fetch_info_and_upload_and_publish(publish_strategy, transcoding_strategy)
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
  # video list
  ######################################################

  def update_video_list!(video_list_id)
    if video_list_id.blank? || video_list_id.zero?
      self.video_list_link.delete if self.video_list_link.present?
      self.video_list_link = nil
    else
      if self.video_list_link.present?
        self.video_list_link.update_attribute(:video_list, VideoList.find(video_list_id))
      else
        self.create_video_list_link(:video_list => VideoList.find(video_list_id))
      end
    end
    self.save! if self.changed?
  end

  def remove_video_list!
    self.video_list_link.delete if self.video_list_link.present?
    self.video_list_link = nil
    self.save! if self.changed?
  end

  ######################################################
  # asynchronous method
  ######################################################

  def fetch_info_and_upload_and_publish(publish_strategy, transcoding_strategy)
    fetch_video_info_and_upload
    publish_by_strategy(publish_strategy, transcoding_strategy)
  end

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
      upload_and_remove_local_mkv
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
          self.original_video.download!
          video_product_group = VideoProductGroup.create(:name => self.video_name, :user_video => self, :owner => self.owner, :creator => self.creator)
          video_product_group.create_package_product
          video_product_group.set_video_list_by_user_video(self)
          self.original_video.remove_local_file!
        end
      when PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
        return if self.format_status == FORMAT_STATUS::BAD_FORMAT_FOR_MTS
        self.transaction do
          self.original_video.download!
          video_product_group = VideoProductGroup.create(:name => self.video_name, :user_video => self, :owner => self.owner, :creator => self.creator, :transcoding_strategy => transcoding_strategy)
          video_product_group.create_products_from_origin
          video_product_group.set_video_list_by_user_video(self)
          self.original_video.remove_local_file!
        end
      when PUBLISH_STRATEGY::TRANSCODING_AND_EDIT
        self.transaction do
          video_product_group = VideoProductGroup.create(:name => '未命名',
                                                         :user_video => self,
                                                         :owner => self.owner,
                                                         :creator => self.creator,
                                                         :status => VideoProductGroup::STATUS::CREATED)
          video_product_group.set_video_list_by_user_video(self)
          self.original_video.remove_local_file!
        end
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
    upload_and_remove_local_mkv
  end

  handle_asynchronously :pre_middle_transcode_finished, :queue => Settings.job_queue.slow

  def upload_and_remove_local_mkv
    transaction do
      self.mkv_video.load_local_file!
      self.mkv_video.remove_local_file!
    end
  end

  ######################################################
  # remove
  ######################################################
  include OSS

  def try_destroy!
    return if self.video_product_groups.present?
    self.videos.destroy_all
    self.destroy!
  end

  def destroy
    return super if self.video_product_groups.blank?
    self.status = STATUS::ORIGIN_DELETED
    self.save
    self.video_cut_points.destroy_all
    self.tags_relationships.delete_all
    self.video_list_link.delete
    self.original_video.destroy if self.original_video
    self.mini_video.destroy if self.mini_video
    self.mkv_video.destroy if self.mkv_video
    self.pre_mkv_video.destroy if self.pre_mkv_video
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
# description                     text                 true            false  
# creator_id                      int(11)              false           false  
#
#------------------------------------------------------------------------------
