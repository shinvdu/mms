class AddTypeToLocalTaskGroups < ActiveRecord::Migration
  def change
    add_column :local_task_groups, :type, :string
  end
end
