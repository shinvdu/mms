class ChangeRoleToStringOnUsers < ActiveRecord::Migration
  def change
    change_column :users, :role, :string
    User.reset_column_information
    User.find(1).update_attribute(:role, Settings.role.root)
  end

end
