class RenameUidToIdOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :uid, :id
  end
end
