class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.integer :uid
      t.string :color
      t.integer :logo
      t.string :logo_position
      t.integer :autoplay
      t.integer :share
      t.integer :full_screen
      t.integer :width
      t.integer :height
      t.text :data

      t.timestamps null: false
    end
  end
end
