class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :user_id
      t.text :desc
      t.text :note

      t.timestamps null: false
    end
  end
end
