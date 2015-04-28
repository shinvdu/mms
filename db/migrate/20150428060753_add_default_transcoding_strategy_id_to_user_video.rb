class AddDefaultTranscodingStrategyIdToUserVideo < ActiveRecord::Migration
  def change
    add_column :user_videos, :default_transcoding_strategy_id, :integer
  end
end
