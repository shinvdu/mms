class AddNameToVideoCutPoint < ActiveRecord::Migration
  def change
    add_column :video_cut_points, :name, :string
  end
end
