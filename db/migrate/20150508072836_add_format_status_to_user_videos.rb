class AddFormatStatusToUserVideos < ActiveRecord::Migration
  def change
    add_column :user_videos, :format_status, :integer, :default => UserVideo::FORMAT_STATUS::NORMAL
  end
end
