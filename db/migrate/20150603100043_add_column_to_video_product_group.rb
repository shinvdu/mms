class AddColumnToVideoProductGroup < ActiveRecord::Migration
  def change
    add_column :video_product_groups, :show_id, "char(20)", after: :id
    add_index :video_product_groups, :show_id,                unique: true
  end
end
