class VideoProductGroupListLink < ActiveRecord::Base
  belongs_to :video_list
  belongs_to :video_product_group
end
