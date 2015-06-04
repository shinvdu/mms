class CreateWaterMarkTemplates < ActiveRecord::Migration
  def change
    create_table :water_mark_templates do |t|
      t.integer :owner_id
      t.integer :creator_id
      t.string :name
      t.integer :width
      t.integer :height
      t.string :refer_pos
      t.string :text
      t.string :img

      t.timestamps null: false
    end
  end
end
