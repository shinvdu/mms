class Player < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :logo
  validates :name, presence: true
  include Privilege
end

#------------------------------------------------------------------------------
# Player
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# name          varchar(255)         true            false  
# user_id       int(11)              true            false  
# color         varchar(255)         true            false  
# logo_id       int(11)              true            false  
# logo_position varchar(255)         true            false  
# autoplay      tinyint(1)           true            false  
# share         tinyint(1)           true            false  
# full_screen   tinyint(1)           true            false  
# width         int(11)              true            false  
# height        int(11)              true            false  
# data          text                 true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
# creator_id        int(11)              true            false  
#
#------------------------------------------------------------------------------
