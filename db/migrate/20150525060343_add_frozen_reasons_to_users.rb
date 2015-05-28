class AddFrozenReasonsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :frozen_reasons, :text
  end
end
