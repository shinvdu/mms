class AddPreMkvVideoToUserVideos < ActiveRecord::Migration
  def change
    add_column :user_videos, :pre_mkv_video_id, :integer
  end
end
