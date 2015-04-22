class VideoFragment < ActiveRecord::Base
  belongs_to :video_product_group
  belongs_to :video_cut_point
end

#------------------------------------------------------------------------------
# VideoFragment
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# video_product_group_id int(11)              true            false  
# video_cut_point_id     int(11)              true            false  
# order                  int(11)              true            false  
# created_at             datetime             false           false  
# updated_at             datetime             false           false  
#
#------------------------------------------------------------------------------
