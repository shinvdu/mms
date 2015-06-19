class RmTagUserIdColumn < ActiveRecord::Migration
  def change
  	remove_column :tags, :user_id
  end
end
