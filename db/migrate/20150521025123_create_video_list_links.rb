class CreateVideoListLinks < ActiveRecord::Migration
  def change
    create_table :video_list_links do |t|
      t.references :video_list
      t.references :user_video

      t.timestamps null: false
    end
  end
end
