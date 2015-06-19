class ChangeColumnsOnVideoDetails < ActiveRecord::Migration
  def change
    change_column :video_details, :duration, :float
    add_column :video_details, :video_codec, :string
    add_column :video_details, :audio_codec, :string
    add_column :video_details, :resolution, :string
  end
end
