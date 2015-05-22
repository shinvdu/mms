class AddIsActiveToAccount < ActiveRecord::Migration
  def change
        add_column :accounts, :is_active, :boolean, after: :email,  :default => true
  end
end
