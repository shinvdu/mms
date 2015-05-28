class CreateProviderAuths < ActiveRecord::Migration
  def change
    if not ActiveRecord::Base.connection.table_exists? 'provider_auths'
      create_table :provider_auths do |t|
        t.integer :user_id
        t.integer :account_id
        t.string :provider_uid
        t.string :provider
        t.boolean :status, default: true

        t.timestamps null: false
      end
    end
  end
end
