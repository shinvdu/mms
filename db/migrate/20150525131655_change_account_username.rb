class ChangeAccountUsername < ActiveRecord::Migration
  def change
  	# remove_column :accounts, :username, :string, :null => true
  	# add_column :accounts, :username, :string, :null => true, after: :id
  	# change_column :accounts, :username, :string, :null => true
  	# change_column :accounts, :email, :string, :null => true
  	remove_index :accounts, :username
  	remove_index :accounts, :email
  	remove_index :accounts, :reset_password_token
  	add_index :accounts, :email, :unique => false
  	add_index :accounts, :reset_password_token, :unique => false
  end
end
