class ChangeColumnsToTranscodings < ActiveRecord::Migration
  def change
    change_column :transcodings, :disabled, :boolean
    add_column :transcodings, :disable_time, :datetime
  end
end
