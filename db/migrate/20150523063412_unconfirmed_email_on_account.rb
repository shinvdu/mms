class UnconfirmedEmailOnAccount < ActiveRecord::Migration
  def change
  	add_column :accounts, :unconfirmed_email, :string, after: :confirmation_sent_at  if !(Account.column_names.include?('unconfirmed_email')) 
  end
end
