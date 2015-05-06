class AddColumnsToVideoDetails < ActiveRecord::Migration
  def change
    add_column :video_details, :public, :boolean, default: false
    add_column :video_details, :public_video, :string
    add_column :video_details, :private_video, :string
    remove_column :video_details, :video
  end
end
