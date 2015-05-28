class AddCreatorToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :creator_id, :integer
  end
end
