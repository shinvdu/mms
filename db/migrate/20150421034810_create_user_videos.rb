class CreateUserVideos < ActiveRecord::Migration
  def change
    create_table :user_videos do |t|
      t.integer :owner_id
      t.integer :original_video_id
      t.integer :mini_video_id
      t.integer :logo_id
      t.string :name
      t.integer :duration
      t.integer :status

      t.timestamps null: false
    end
  end
end
