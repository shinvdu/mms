class AddVideoIdToResource < ActiveRecord::Migration
  def change
    add_column :advertise_resources, :video_detail_id, :integer
  end
end
