class CreateOneTimeTokens < ActiveRecord::Migration
  def change
    create_table :one_time_tokens do |t|
      t.boolean :used, :default => false
      t.string :token, :index => true
      t.datetime :expire_time
      t.references :cache_form, foreign_key: true

      t.timestamps null: false
    end
  end
end
