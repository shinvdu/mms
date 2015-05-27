class AddCreatorOnTranscodings < ActiveRecord::Migration
  def change
    add_column :transcodings, :creator_id, :integer, :null => false
  end
end
