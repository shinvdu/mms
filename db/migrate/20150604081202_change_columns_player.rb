class ChangeColumnsPlayer < ActiveRecord::Migration
  def change
  	rename_column :players, :data, :whitelist
  end
end
