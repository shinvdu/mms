class AddPrivilegesOnVideoListPrivileges < ActiveRecord::Migration
  def change
    add_column :video_list_privileges, :can_edit, :boolean, :default => false
    add_column :video_list_privileges, :can_clip, :boolean, :default => false
    add_column :video_list_privileges, :can_publish, :boolean, :default => false
    add_column :video_list_privileges, :can_upload, :boolean, :default => false
    add_column :video_list_privileges, :can_delete, :boolean, :default => false
  end
end
