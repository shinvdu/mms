class AddNameToVideoProductGroups < ActiveRecord::Migration
  def change
    add_column :video_product_groups, :name, :string
  end
end
