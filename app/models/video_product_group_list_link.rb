class VideoProductGroupListLink < ActiveRecord::Base
  belongs_to :video_list
  belongs_to :video_product_group
end

#------------------------------------------------------------------------------
# VideoProductGroupListLink
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# video_list_id          int(11)              true            false  
# video_product_group_id int(11)              true            false  
# created_at             datetime             false           false  
# updated_at             datetime             false           false  
#
#------------------------------------------------------------------------------
