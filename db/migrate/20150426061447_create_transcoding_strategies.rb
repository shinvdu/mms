class CreateTranscodingStrategies < ActiveRecord::Migration
  def change
    create_table :transcoding_strategies do |t|
      t.string :name
      t.integer :user_id
      t.text :data
      t.text :note

      t.timestamps null: false
    end
  end
end
