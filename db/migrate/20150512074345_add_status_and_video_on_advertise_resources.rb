class AddStatusAndVideoOnAdvertiseResources < ActiveRecord::Migration
  def change
    add_column :advertise_resources, :status, :integer
    add_column :advertise_resources, :format_status, :integer, default: Advertise::Resource::FORMAT_STATUS::NORMAL
    add_column :advertise_resources, :transcoded_video_id, :integer
  end
end
