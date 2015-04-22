class CreateVideoFragments < ActiveRecord::Migration
  def change
    create_table :video_fragments do |t|
      t.integer :video_product_group_id
      t.integer :video_cut_point_id
      t.integer :order

      t.timestamps null: false
    end
  end
end
