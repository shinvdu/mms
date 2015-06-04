class Transcoding < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  belongs_to :creator, :class_name => 'User'
  has_many :transcoding_strategy_relationships
  scope :visible, -> (user) { where(['(user_id = ? or share=true) and disabled=false', user.owner.uid]) }
  scope :find_mini_template, -> { order('id desc').find_by_special_template(SPECIAL_TEMPLATE::MINI_TEMPLATE) }
  scope :find_ad_template, -> { order('id desc').find_by_special_template(SPECIAL_TEMPLATE::AD_TEMPLATE) }
  scope :find_pre_middle_template, -> { order('id desc').find_by_special_template(SPECIAL_TEMPLATE::PRE_MIDDLE_TEMPLATE) }

  validates :name, presence: true
  validates :container, presence: true, inclusion: {in: %w(mp4 flv ts m3u8), message: "%{value} is not a valid format"}
  validates :video_codec, inclusion: {in: %w(H.264), message: "%{value} is not a valid 编解码格式"}, :allow_nil => true
  validates :video_profile, presence: true, inclusion: {in: %w(baseline main high ), message: "%{value} is not a valid 编码级别"}
  validates :video_bitrate, numericality: {only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 50000}, :allow_nil => true
  validates :video_crf, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 51}, :allow_nil => true
  validates :width, numericality: {greater_than_or_equal_to: 128, less_than_or_equal_to: 4096}, :allow_nil => true
  validates :height, numericality: {greater_than_or_equal_to: 128, less_than_or_equal_to: 4096}, :allow_nil => true
  validates :video_fps, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 60}, :allow_nil => true
  validates :video_gop, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 1080000}
  validates :video_preset, presence: true, inclusion: {in: %w(veryfast fast medium slow slower veryslow), message: "%{value} is not a valid 视频算法器预置"}
  validates :video_scanmode, presence: true, inclusion: {in: %w(interlaced progressive), message: "%{value} is not a valid 扫描模式"}
  validates :video_bufsize, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 128000}
  validates :video_maxrate, numericality: {only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 50000}, :allow_nil => true
  validates :video_bitrate_bnd_max, numericality: {only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 50000}, :allow_nil => true
  validates :video_bitrate_bnd_min, numericality: {only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 50000}, :allow_nil => true
  validates :audio_codec, presence: true, inclusion: {in: %w(aac mp3), message: "%{value} is not a valid 音频编解码格式"}
  validates :audio_samplerate, presence: true, inclusion: {in: [22050, 32000, 44100, 48000, 96000], message: "%{value} is not a valid 采样率"}
  validates :audio_bitrate, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 8, less_than_or_equal_to: 1000}
  validates :audio_channels, presence: true, inclusion: {in: [1, 2, 3, 4, 5, 6, 7, 8], message: "%{value} is not a valid 声道数"}

  module SPECIAL_TEMPLATE
    NONE = 0
    MINI_TEMPLATE = 1
    MIDDLE_TEMPLATE = 2
    PRE_MIDDLE_TEMPLATE = 3
    AD_TEMPLATE = 4
  end

  include MTSWorker::TranscodingWorker

  def do_save
    begin
      transaction do
        self.save!
        upload_and_save!
        self
      end
    rescue Exception => e
      logger.error e
      nil
    end
  end

  def disable_and_destroy!
    self.disabled = true
    self.delay.delete_self_and_template if self.aliyun_template_id.present?
    self.save!
  end

  def delete_self_and_template
    self.delete_aliyun_template(self)
    self.destroy!
  end

  def disable!
    self.disabled = true
    self.disable_time = Time.now
    self.delay.delete_aliyun_template(self) if self.aliyun_template_id.present?
    self.save!
  end

  def update_by_create!(params)
    begin
      transaction do
        new_transcoding = self.dup
        new_transcoding.update!(params)
        if !update_aliyun_template(new_transcoding)
          rails 'updating mts transcoding failed.'
        end
        self.disabled = true
        self.disable_time = Time.now
        self.save!
        self.transcoding_strategy_relationships.each do |relation|
          relation.transcoding = new_transcoding
          relation.save!
        end
        new_transcoding
      end
    rescue Exception => e
      logger.error e
      logger.error "updating by create transcoding failed. id: #{self.id}"
      nil
    end
  end

  def update_directly(params)
    begin
      transaction do
        self.update!(params)
        if !update_aliyun_template(self)
          rails 'updating mts transcoding failed.'
        end
        self
      end
    rescue Exception => e
      logger.error e
      logger.error "updating transcoding template failed. id: #{self.id}"
      nil
    end
  end

  def mini_transcoding?
    self.special_template == SPECIAL_TEMPLATE::MINI_TEMPLATE
  end
end

#------------------------------------------------------------------------------
# Transcoding
#
# Name                  SQL Type             Null    Default Primary
# --------------------- -------------------- ------- ------- -------
# id                    int(11)              false           true   
# name                  varchar(255)         true            false  
# user_id               int(11)              true            false  
# container             varchar(255)         true            false  
# video_profile         varchar(255)         true            false  
# video_preset          varchar(255)         true            false  
# audio_codec           varchar(255)         true            false  
# audio_samplerate      int(11)              true            false  
# audio_bitrate         int(11)              true            false  
# width                 int(11)              true            false  
# height                int(11)              true            false  
# created_at            datetime             false           false  
# updated_at            datetime             false           false  
# video_codec           varchar(255)         true            false  
# video_bitrate         int(11)              true            false  
# video_crf             int(11)              true            false  
# video_fps             int(11)              true            false  
# video_gop             int(11)              true            false  
# video_scanmode        varchar(255)         true            false  
# video_bufsize         int(11)              true            false  
# video_maxrate         int(11)              true            false  
# video_bitrate_bnd_max int(11)              true            false  
# audio_channels        int(11)              true            false  
# state                 varchar(255)         true            false  
# aliyun_template_id    varchar(255)         true            false  
# video_bitrate_bnd_min int(11)              true            false  
# disabled              tinyint(1)           true    0       false  
# disable_time          datetime             true            false  
# share                 tinyint(1)           true    0       false  
# special_template      int(11)              true    0       false  
# creator_id            int(11)              false           false  
#
#------------------------------------------------------------------------------
