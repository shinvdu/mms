class CreateAdvertiseResources < ActiveRecord::Migration
  def change
    create_table :advertise_resources do |t|
      t.string :name
      t.integer :user_id
      t.string :file_type
      t.string :ad_type
      t.integer :filesize
      t.string :uri
      t.text :ad_word
      t.text :data

      t.timestamps null: false
    end
  end
end
