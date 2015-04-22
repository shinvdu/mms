class AddVideoToVideoDetail < ActiveRecord::Migration
  def change
    add_column :video_details, :video, :string
  end
end
