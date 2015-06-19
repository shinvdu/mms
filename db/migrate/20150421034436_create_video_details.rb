class CreateVideoDetails < ActiveRecord::Migration
  def change
    create_table :video_details do |t|
      t.string :uuid
      t.string :uri
      t.string :format
      t.string :md5
      t.string :rate
      t.integer :size
      t.integer :duration
      t.integer :status
      t.integer :user_video_id

      t.timestamps null: false
    end
  end
end
