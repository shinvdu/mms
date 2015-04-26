class CreateTranscodingStrategyRelationships < ActiveRecord::Migration
  def change
    create_table :transcoding_strategy_relationships do |t|
      t.integer :transcoding_id
      t.integer :transcoding_strategy_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
