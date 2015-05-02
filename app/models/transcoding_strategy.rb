class TranscodingStrategy < ActiveRecord::Base
  belongs_to :user
  has_many :transcoding_strategy_relationships
  has_many :transcodings, :through => :transcoding_strategy_relationships, :source => :transcoding
  scope :visiable, -> (user) { where(['user_id = ? or share', user.uid]) }
end

#------------------------------------------------------------------------------
# TranscodingStrategy
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# user_id    int(11)              true            false  
# note       text                 true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
#
#------------------------------------------------------------------------------
