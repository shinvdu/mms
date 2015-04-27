class VideoCutPoint < ActiveRecord::Base
  belongs_to :user_video
end

#------------------------------------------------------------------------------
# VideoCutPoint
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# start_time    float                true            false  
# stop_time     float                true            false  
# user_created  tinyint(1)           true            false  
# user_video_id int(11)              true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
# name          varchar(255)         true            false  
#
#------------------------------------------------------------------------------
