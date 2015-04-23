class ChangeColumnLogoPlayer < ActiveRecord::Migration
  def change
  	rename_column :logos, :uid, :user_id
  	rename_column :players, :uid, :user_id
  end
end
