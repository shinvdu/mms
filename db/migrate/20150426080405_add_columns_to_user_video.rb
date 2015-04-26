class AddColumnsToUserVideo < ActiveRecord::Migration
  def change
    add_column :user_videos, :width, :integer
    add_column :user_videos, :height, :integer
  end
end
