class AddToOneTimeTOken < ActiveRecord::Migration
  def change
  	add_column :one_time_tokens, :user_id, :integer, after: :id
  end
end
