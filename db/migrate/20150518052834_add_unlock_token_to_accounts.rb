class AddUnlockTokenToAccounts < ActiveRecord::Migration
  def change
        add_column :accounts, :unlock_token, :string, after: :failed_attempts
  end
end
