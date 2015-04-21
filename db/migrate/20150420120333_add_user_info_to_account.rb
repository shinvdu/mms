class AddUserInfoToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :user_info_id, :integer
  end
end
