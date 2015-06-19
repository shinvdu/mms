class ChangeColumnsOnTranscodings < ActiveRecord::Migration
  def change
    remove_column :transcodings, :video_line_scan
    remove_column :transcodings, :h_w_percent
    remove_column :transcodings, :data
    add_column :transcodings, :share, :boolean, default: false
  end
end
