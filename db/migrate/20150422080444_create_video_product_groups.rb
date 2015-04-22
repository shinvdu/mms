class CreateVideoProductGroups < ActiveRecord::Migration
  def change
    create_table :video_product_groups do |t|
      t.integer :owner_id
      t.integer :user_video_id
      t.integer :video_config_id
      t.boolean :published
      t.time :publish_start
      t.time :publish_stop
      t.integer :status

      t.timestamps null: false
    end
  end
end
