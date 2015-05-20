class AddMobileVerifyToUsers < ActiveRecord::Migration
  def change
        add_column :users, :mobile_verify, :boolean, after: :mobile,  :default => false
  end
end
