class CreateEnabledWaterMarks < ActiveRecord::Migration
  def change
    create_table :enabled_water_marks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :water_mark_template, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
