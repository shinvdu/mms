class AddTranscodingStrategyToVideoProductGroup < ActiveRecord::Migration
  def change
    add_column :video_product_groups, :transcoding_strategy_id, :integer
  end
end
