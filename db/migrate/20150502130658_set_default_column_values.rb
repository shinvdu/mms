class SetDefaultColumnValues < ActiveRecord::Migration
  def change
    change_column :local_tasks, :status, :integer, :default => 10
    change_column :mts_jobs, :status, :integer, :default => 10
    change_column :transcodings, :disabled, :boolean, :default => false
    change_column :video_products, :status, :integer, :default => 10
    change_column :video_product_fragments, :status, :integer, :default => 10
    change_column :video_product_groups, :status, :integer, :default => 10
    change_column :local_task_groups, :status, :integer, :default => 10
  end
end
