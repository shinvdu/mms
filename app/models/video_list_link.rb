class VideoListLink < ActiveRecord::Base
  belongs_to :video_list
  belongs_to :user_video
end

#------------------------------------------------------------------------------
# VideoListLink
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# video_list_id int(11)              true            false  
# user_video_id int(11)              true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
#
#------------------------------------------------------------------------------
