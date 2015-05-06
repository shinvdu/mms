class AddMkvVideoToVideoProductGroups < ActiveRecord::Migration
  def change
    add_column :video_product_groups, :mkv_video_id, :integer
  end
end
