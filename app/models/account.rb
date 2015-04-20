class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]
  attr_accessor :login
  
  def self.find_for_database_authentication(warden_conditions)
  	conditions = warden_conditions.dup
  	if login = conditions.delete(:login)
  		where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  	else
  		where(conditions.to_h).first
  	end
  end
end

#------------------------------------------------------------------------------
# Account
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# email                  varchar(255)         false           false  
# encrypted_password     varchar(255)         false           false  
# reset_password_token   varchar(255)         true            false  
# reset_password_sent_at datetime             true            false  
# remember_created_at    datetime             true            false  
# sign_in_count          int(11)              false   0       false  
# current_sign_in_at     datetime             true            false  
# last_sign_in_at        datetime             true            false  
# current_sign_in_ip     varchar(255)         true            false  
# last_sign_in_ip        varchar(255)         true            false  
# created_at             datetime             true            false  
# updated_at             datetime             true            false  
#
#------------------------------------------------------------------------------
