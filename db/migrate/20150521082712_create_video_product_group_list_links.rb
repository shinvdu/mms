class CreateVideoProductGroupListLinks < ActiveRecord::Migration
  def change
    create_table :video_product_group_list_links do |t|
      t.references :video_list, index: true, foreign_key: true
      t.references :video_product_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
