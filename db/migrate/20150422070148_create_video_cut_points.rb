class CreateVideoCutPoints < ActiveRecord::Migration
  def change
    create_table :video_cut_points do |t|
      t.float :start_time
      t.float :stop_time
      t.boolean :user_created
      t.integer :user_video_id

      t.timestamps null: false
    end
  end
end
