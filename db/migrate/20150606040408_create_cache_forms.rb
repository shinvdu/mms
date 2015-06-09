class CreateCacheForms < ActiveRecord::Migration
  def change
    create_table :cache_forms do |t|
      t.references :user, index: true, foreign_key: true
      t.text :params
      t.string :handler

      t.timestamps null: false
    end
  end
end
