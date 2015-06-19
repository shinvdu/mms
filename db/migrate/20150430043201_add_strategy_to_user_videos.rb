class AddStrategyToUserVideos < ActiveRecord::Migration
  def change
    add_column :user_videos, :strategy, :integer
  end
end
