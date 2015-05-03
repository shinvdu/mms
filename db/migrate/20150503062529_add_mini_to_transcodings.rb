class AddMiniToTranscodings < ActiveRecord::Migration
  def change
    add_column :transcodings, :mini, :boolean, default: false
    Transcoding.reset_column_information
    Transcoding.find(1).update_attribute(:mini, true)
  end
end
