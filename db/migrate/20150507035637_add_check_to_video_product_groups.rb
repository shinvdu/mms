class AddCheckToVideoProductGroups < ActiveRecord::Migration
  def change
    add_column :video_product_groups, :check_status, :integer, default: VideoProductGroup::CHECK_STATUS::UNCHECKED
    add_column :video_product_groups, :checker_id, :integer
  end
end
