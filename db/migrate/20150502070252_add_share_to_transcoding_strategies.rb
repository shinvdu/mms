class AddShareToTranscodingStrategies < ActiveRecord::Migration
  def change
    add_column :transcoding_strategies, :share, :boolean
  end
end
