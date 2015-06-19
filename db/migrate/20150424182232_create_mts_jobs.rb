class CreateMtsJobs < ActiveRecord::Migration
  def change
    create_table :mts_jobs do |t|
      t.string :type
      t.string :request_id
      t.integer :status
      t.time :finish_time
      t.string :message
      t.integer :target_id

      t.timestamps null: false
    end
  end
end
