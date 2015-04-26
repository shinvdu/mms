class AddColumnsToVideoDetail < ActiveRecord::Migration
  def change
    add_column :video_details, :width, :integer
    add_column :video_details, :height, :integer
    add_column :video_details, :fps, :integer
  end
end
