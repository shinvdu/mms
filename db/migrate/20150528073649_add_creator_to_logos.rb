class AddCreatorToLogos < ActiveRecord::Migration
  def change
    add_column :logos, :creator_id, :integer
  end
end
