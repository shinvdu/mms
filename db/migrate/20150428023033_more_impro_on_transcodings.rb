class MoreImproOnTranscodings < ActiveRecord::Migration
  def change
    rename_column :transcodings, :video_bitratebnd, :video_bitrate_bnd_max
    add_column :transcodings, :video_bitrate_bnd_min, :integer
    add_column :transcodings, :disabled, :integer

  end
end
