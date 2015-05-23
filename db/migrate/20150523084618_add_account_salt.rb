class AddAccountSalt < ActiveRecord::Migration
  def change
  	add_column :accounts, :password_salt, :string, after: :encrypted_password
  end
end
