class ChangeUserNicename < ActiveRecord::Migration
  def change
    rename_column :users, :nicename, :nickname 
  end
end
