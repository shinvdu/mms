class TagsRelationship < ActiveRecord::Base
  belongs_to :tag
  belongs_to :user
  belongs_to :user_video
end

#------------------------------------------------------------------------------
# TagsRelationship
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# tag_id        int(11)              true            false  
# user_video_id int(11)              true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
# user_id       int(11)              true            false  
#
#------------------------------------------------------------------------------
