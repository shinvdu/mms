class CreateVideoProductFragments < ActiveRecord::Migration
  def change
    create_table :video_product_fragments do |t|
      t.integer :video_product_id
      t.integer :video_fragment_id
      t.integer :video_detail_id
      t.integer :order
      t.integer :status

      t.timestamps null: false
    end
  end
end
