class ChangeReallyName < ActiveRecord::Migration
  def change
    change_column :users, :really_name,  :string
  end
end
