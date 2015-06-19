class AddColumnUserIdToUser < ActiveRecord::Migration
  def change
    add_column :tags_relationships, :user_id, :integer
  end
end
