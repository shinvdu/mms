class CreateLocalTaskGroups < ActiveRecord::Migration
  def change
    create_table :local_task_groups do |t|
      t.integer :status
      t.integer :target_id
      t.timestamp :finish_time
      t.string :message
      t.timestamp :prediction_time
      t.integer :percent

      t.timestamps null: false
    end
  end
end
