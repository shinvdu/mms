class RmUseTypeFromResource < ActiveRecord::Migration
  def change
    remove_column :advertise_resources, :use_type, :string
  end
end
