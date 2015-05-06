class AddPostProcessCommandToMtsJobs < ActiveRecord::Migration
  def change
    add_column :mts_jobs, :post_process_command, :string
  end
end
