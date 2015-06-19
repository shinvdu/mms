class ChangeMkvVideoToTempVideoOnVideoProductGroups < ActiveRecord::Migration
  def change
    rename_column :video_product_groups, :mkv_video_id, :temp_video_id
  end
end
