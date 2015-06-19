class ChangeUserAvar < ActiveRecord::Migration
  def change
  	change_column :users, :avar,  :string
  end
end
