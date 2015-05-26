class VideoListPrivilege < ActiveRecord::Base
  belongs_to :user
  belongs_to :video_list
end
