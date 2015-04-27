class AddTranscodingStrategyToUserVideo < ActiveRecord::Migration
  def change
    add_column :user_videos, :transcoding_strategy_id, :integer
  end
end
