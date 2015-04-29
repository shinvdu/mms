class AddTypeToLocalTasks < ActiveRecord::Migration
  def change
    add_column :local_tasks, :type, :string
  end
end
