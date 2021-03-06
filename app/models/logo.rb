class Logo < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  validates :name, presence: true
  validates :uri,  presence: { message: I18n.t('model.logo.logo_require') }
  include Privilege

  mount_uploader :uri, LogoUploader  if not Rails.env.test?

end

#------------------------------------------------------------------------------
# Logo
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# user_id    int(11)              true            false  
# uri        varchar(255)         true            false  
# width      int(11)              true            false  
# height     int(11)              true            false  
# filemime   varchar(255)         true            false  
# filesize   int(11)              true            false  
# origname   varchar(255)         true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
# creator_id   int(11)              true            false  
#
#------------------------------------------------------------------------------
