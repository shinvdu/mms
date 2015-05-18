class ChangeUserSmsVerify < ActiveRecord::Migration
  def change
    remove_column :users, :mobile_verify
    add_column :users, :mobile_verify_at, :datetime, after: :mobile
  end
end
