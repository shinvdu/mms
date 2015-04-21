class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :primary_key => :uid do |t|
      t.string :nicename
      t.integer :role
      # personal
      t.integer :sex
      t.integer :really_name
      t.datetime :birthday
      t.string :signature
      t.integer :avar
      t.string :location
      t.string :self_introduction

      # Authorize
      t.string :token
      t.string :scret_key

      # contact
      t.string :mobile
      t.string :wechat
      t.string :qq
      t.string :weibo
      t.string :twitter_id
      t.string :facebook
      t.string :website

      t.string :note

      t.timestamps null: false
    end
  end
end
