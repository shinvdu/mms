class CreateVideoProducts < ActiveRecord::Migration
  def change
    create_table :video_products do |t|
      t.integer :video_product_group_id
      t.integer :video_detail_id
      t.integer :transcoding_id
      t.integer :progress
      t.integer :status

      t.timestamps null: false
    end
  end
end
