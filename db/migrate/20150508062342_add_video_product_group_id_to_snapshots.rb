class AddVideoProductGroupIdToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :video_product_group_id, :integer
  end
end
