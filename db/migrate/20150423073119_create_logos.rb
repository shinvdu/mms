class CreateLogos < ActiveRecord::Migration
  def change
    create_table :logos do |t|
      t.string :name
      t.integer :uid
      t.string :uri
      t.integer :width
      t.integer :height
      t.string :filemime
      t.integer :filesize
      t.string :origname

      t.timestamps null: false
    end
  end
end
