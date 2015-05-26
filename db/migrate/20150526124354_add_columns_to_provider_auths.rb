class AddColumnsToProviderAuths < ActiveRecord::Migration
  def change
    add_column :provider_auths, :access_token, :string
  end
end
