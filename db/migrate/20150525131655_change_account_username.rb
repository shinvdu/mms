class ChangeAccountUsername < ActiveRecord::Migration
  def change
  	# remove_column :accounts, :username, :string, :null => true
  	add_column :accounts, :username, :string, :null => true, after: :id
  end
end
