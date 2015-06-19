class CreateLocalTasks < ActiveRecord::Migration
  def change
    create_table :local_tasks do |t|
      t.integer :status
      t.integer :target_id
      t.timestamp :finish_time
      t.string :message
      t.timestamp :prediction_time
      t.integer :percent
      t.integer :local_task_group_id
      t.integer :dependency_id

      t.timestamps null: false
    end
  end
end
