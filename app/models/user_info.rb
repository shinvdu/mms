class UserInfo < ActiveRecord::Base
  has_one :account
  has_many :user_videos, :foreign_key => :owner_id
end

#------------------------------------------------------------------------------
# UserInfo
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# note       text                 true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
#
#------------------------------------------------------------------------------
