class AddMiddleToTranscodings < ActiveRecord::Migration
  def change
    add_column :transcodings, :middle, :boolean
  end
end
