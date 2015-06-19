class ChangeMtsJobs < ActiveRecord::Migration
  def change
    rename_column :mts_jobs, :request_id, :job_id
    add_column :mts_jobs, :code, :string
    add_column :mts_jobs, :percent, :integer
  end
end

