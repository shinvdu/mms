class AddMkvVideoToUserVideo < ActiveRecord::Migration
  def change
    add_column :user_videos, :mkv_video_id, :integer
  end
end
