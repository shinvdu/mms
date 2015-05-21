class CreateVideoLists < ActiveRecord::Migration
  def change
    create_table :video_lists do |t|
      t.string :name
      t.integer :owner_id

      t.timestamps null: false
    end
  end
end
