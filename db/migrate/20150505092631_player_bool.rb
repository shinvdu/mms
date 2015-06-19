class PlayerBool < ActiveRecord::Migration
  def change
    change_column :players, :autoplay, :boolean
    change_column :players, :share, :boolean
    change_column :players, :full_screen, :boolean
  end
end
