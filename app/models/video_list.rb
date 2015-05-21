class VideoList < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :video_list_links
  has_many :user_videos, :through => :video_list_links
  scope :get_by_user, -> (user) {where(:owner => user)}
end

#------------------------------------------------------------------------------
# VideoList
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# owner_id   int(11)              true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
#
#------------------------------------------------------------------------------
