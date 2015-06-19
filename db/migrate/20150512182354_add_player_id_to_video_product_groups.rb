class AddPlayerIdToVideoProductGroups < ActiveRecord::Migration
  def change
    add_column :video_product_groups, :player_id, :integer
  end
end
