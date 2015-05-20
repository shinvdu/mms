class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.boolean :is_read
      t.string :title
      t.integer :target_id
      t.string :target_type

      t.timestamps null: false
    end
  end
end
