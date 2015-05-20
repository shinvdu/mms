class User < ActiveRecord::Base
  self.primary_key = "uid"
  has_one :account
  has_many :notifications
  has_many :logos
  has_many :players
  has_many :advertise_resources, :class_name => 'Advertise::Resource'
  has_many :advertise_strategies, :class_name => 'Advertise::Strategy'
  has_many :transcoding_strategies
  # has_one :logo
  # has_many :player
  # has_many :resource
  # has_many :strategy
  # has_many :transcoding
  # has_many :transcoding_strategy
  # has_many :transcoding_strategy_relationship
  # has_many :tag
  # has_many :tags_relationship
  has_many :notification
  has_many :user_videos, :foreign_key => :owner_id
  # mount_uploader :avar, AvatarUploader
  # 短信验证
  has_sms_verification

  alias_attribute :id, :uid
  alias_attribute :avatar, :avar
  alias_attribute :phone, :mobile
  alias_attribute :verified_at, :mobile_verify_at


  def admin?
    # TODO 第一个用户为超级用户
    self.role == Settings.role.root
  end

  Settings.role.values.each do |role|
    class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{role}?
          self.role == '#{role}'
        end
    METHOD
  end

  def unread_messages
    messages = Notification.where(user_id: self.uid).where(is_read: nil).order(created_at: :desc)
  end

end

#------------------------------------------------------------------------------
# User
#
# Name              SQL Type             Null    Default Primary
# ----------------- -------------------- ------- ------- -------
# uid               int(11)              false           true   
# nickname          varchar(255)         true            false  
# role              int(11)              true            false  
# sex               int(11)              true            false  
# really_name       int(11)              true            false  
# birthday          datetime             true            false  
# signature         varchar(255)         true            false  
# avar              varchar(255)         true            false  
# location          varchar(255)         true            false  
# self_introduction varchar(255)         true            false  
# token             varchar(255)         true            false  
# scret_key         varchar(255)         true            false  
# mobile            varchar(255)         true            false  
# wechat            varchar(255)         true            false  
# qq                varchar(255)         true            false  
# weibo             varchar(255)         true            false  
# twitter_id        varchar(255)         true            false  
# facebook          varchar(255)         true            false  
# website           varchar(255)         true            false  
# note              varchar(255)         true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
