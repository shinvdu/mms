class RenameLogosLog < ActiveRecord::Migration
  def change
  	rename_column :players, :logo, :logo_id
  end
end
