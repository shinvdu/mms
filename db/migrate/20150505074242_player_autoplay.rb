class PlayerAutoplay < ActiveRecord::Migration
  def change
    change_column :players, :autoplay, :string
  end
end
