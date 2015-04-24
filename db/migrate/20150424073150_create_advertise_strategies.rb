class CreateAdvertiseStrategies < ActiveRecord::Migration
  def change
    create_table :advertise_strategies do |t|
      t.string :name
      t.integer :user_id
      t.integer :front_ad
      t.integer :end_ad
      t.integer :pause_ad
      t.integer :float_ad
      t.integer :scroll_ad
      t.text :data

      t.timestamps null: false
    end
  end
end
