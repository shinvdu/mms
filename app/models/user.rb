class User < ActiveRecord::Base
  scope :inactive, -> {joins(:account).where(:accounts => {:is_active => false})}
  scope :active, -> {joins(:account).where(:accounts => {:is_active => true})}
  has_one :account
  has_one :avatar
  has_one :enabled_water_mark
  has_many :notifications
  has_many :logos
  has_many :provider_auths
  has_many :players
  has_many :advertise_resources, :class_name => 'Advertise::Resource'
  has_many :advertise_strategies, :class_name => 'Advertise::Strategy'
  has_many :transcoding_strategies
  has_many :notification
  has_many :user_videos, :foreign_key => :owner_id
  has_many :video_product_groups, :foreign_key => :owner_id
  has_many :video_list_privileges, :dependent => :delete_all
  has_many :video_lists, :through => :video_list_privileges
  has_many :daily_flow_stats, :class_name => 'Statistics::DailyFlowStat'
  has_many :daily_loading_stats, :class_name => 'Statistics::DailyLoadingStat'
  has_many :daily_space_stats, :class_name => 'Statistics::DailySpaceStat'
  belongs_to :company
  accepts_nested_attributes_for :company, :account
  # mount_uploader :avar, AvatarUploader
  # 短信验证
  has_sms_verification

  alias_attribute :uid, :id
  # alias_attribute :avatar, :avar
  alias_attribute :phone, :mobile
  alias_attribute :verified_at, :mobile_verify_at

  module FROZEN_REASON
    COMPANY_ADMIN = 'company admin'
    COMPANY_FROZEN = 'system admin froze company'
  end

  Settings.role.values.each do |role|
    class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{role}?
          self.role == '#{role}'
        end
        scope :#{role}s, -> {where(:role => Settings.role.#{role})}
    METHOD
  end
  alias_method :admin?, :root? # must be after definition

  def owner
    self.company.present? ? self.company.owner : self
  end

  def activate
    transaction do
      self.account.activate!
    end
  end

  def inactivate(reason, operator)
    transaction do
      self.frozen_reasons = JSON.parse(self.frozen_reasons).append(make_reason(reason, operator)).to_json
      self.account.inactivate!
      self.save!
    end
  end

  def frozen_reason
    JSON.parse(self.frozen_reasons).last
  end

  def unread_messages
    messages = Notification.where(user_id: self.uid).where(is_read: nil).order(created_at: :desc)
  end

  def frozen_reasons
    super || '[]'
  end

  def enabled_water_mark
    ret = super
    self.create_enabled_water_mark(:user => self) if ret.nil?
    super
  end

  private

  def make_reason(reason, operator)
    {:reason => reason, :operator_id => operator.id, :operator_name => operator.nickname}
  end
end

#------------------------------------------------------------------------------
# User
#
# Name              SQL Type             Null    Default Primary
# ----------------- -------------------- ------- ------- -------
# id                int(11)              false           true   
# nickname          varchar(255)         true            false  
# role              varchar(255)         true            false  
# sex               int(11)              true            false  
# really_name       varchar(255)         true            false  
# birthday          datetime             true            false  
# signature         varchar(255)         true            false  
# avar              varchar(255)         true            false  
# location          varchar(255)         true            false  
# self_introduction varchar(255)         true            false  
# token             varchar(255)         true            false  
# scret_key         varchar(255)         true            false  
# mobile            varchar(255)         true            false  
# mobile_verify_at  datetime             true            false  
# wechat            varchar(255)         true            false  
# qq                varchar(255)         true            false  
# weibo             varchar(255)         true            false  
# twitter_id        varchar(255)         true            false  
# facebook          varchar(255)         true            false  
# website           varchar(255)         true            false  
# note              varchar(255)         true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
# company_id        int(11)              true            false  
# frozen_reasons    text                 true            false  
#
#------------------------------------------------------------------------------
