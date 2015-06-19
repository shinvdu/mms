class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :lockable, :encryptable, :omniauthable
  # devise :authentication_keys => [:login]
  devise :confirmable if Rails.env == 'production'
  belongs_to :user, foreign_key: :user_id
  # validates_uniqueness_of :username
  # validates :username, presence: true
  accepts_nested_attributes_for :user
  
  # def self.find_for_database_authentication(warden_conditions)
  #   conditions = warden_conditions.dup
  #   if login = conditions.delete(:login)
  #     where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", {:value => login.downcase}]).first
  #   else
  #     where(conditions.to_h).first
  #   end
  # end

  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super and self.is_active?
  end

  def activate!
    self.is_active = true
    self.save!
  end

  def inactivate!
    self.is_active = false
    self.save!
  end
  
  def self.from_omniauth(auth)
    p_auth = ProviderAuth.find_for_oauth(auth)
    if not p_auth.user
      u = User.new
      u.nickname = auth.info.nickname
      u.save
      p_auth.user  = u
      p_auth.save
      account = Account.new
      account.username = auth.info.nickname
      account.user = u
      account.save
      account
    else
      p_auth.user.account
    end
  end

  def self.new_with_session(params, session)
    if session["devise.account_attributes"]
      new(session["devise.account_attributes"], without_protection: true) do |account|
        account.attributes = params
        account.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def email_required?
    super && provider.blank?
  end

  def username_required?
    super &&  provider.blank?
  end


  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end 

  def provider
    self.user && self.user.provider_auths && (provider = self.user.provider_auths.first) && provider.provider
  end

end

module UsernameValidatable
  def username_required?
    true
  end
  def self.included(base)
    base.class_eval do
      validates_presence_of   :username, if: :username_required?
    end
  end
end

Account.send(:include, UsernameValidatable)

#------------------------------------------------------------------------------
# Account
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# username               varchar(255)         false           false  
# email                  varchar(255)         false           false  
# is_active              tinyint(1)           true    1       false  
# encrypted_password     varchar(255)         false           false  
# password_salt          varchar(255)         true            false  
# reset_password_token   varchar(255)         true            false  
# reset_password_sent_at datetime             true            false  
# remember_created_at    datetime             true            false  
# sign_in_count          int(11)              false   0       false  
# current_sign_in_at     datetime             true            false  
# last_sign_in_at        datetime             true            false  
# current_sign_in_ip     varchar(255)         true            false  
# last_sign_in_ip        varchar(255)         true            false  
# confirmation_token     varchar(255)         true            false  
# confirmed_at           datetime             true            false  
# confirmation_sent_at   datetime             true            false  
# unconfirmed_email      varchar(255)         true            false  
# failed_attempts        int(11)              false   0       false  
# unlock_token           varchar(255)         true            false  
# locked_at              datetime             true            false  
# user_id                int(11)              true            false  
# created_at             datetime             true            false  
# updated_at             datetime             true            false  
#
#------------------------------------------------------------------------------
