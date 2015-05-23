class UnconfirmedEmailOnAccount < ActiveRecord::Migration
  def change
  	add_column :accounts, :unconfirmed_email, :string, after: :confirmation_sent_at
  end
end
