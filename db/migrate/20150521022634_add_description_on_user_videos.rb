class AddDescriptionOnUserVideos < ActiveRecord::Migration
  def change
    add_column :user_videos, :description, :text
  end
end
