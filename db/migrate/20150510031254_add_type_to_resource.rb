class AddTypeToResource < ActiveRecord::Migration
  def change
    add_column :advertise_resources, :use_type, :string
  end
end
