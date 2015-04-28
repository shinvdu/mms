class Tag < ActiveRecord::Base
  has_many :tags_relationship
  belongs_to :user
end

#------------------------------------------------------------------------------
# Tag
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# desc       text                 true            false  
# note       text                 true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
# user_id    int(11)              true            false  
#
#------------------------------------------------------------------------------
