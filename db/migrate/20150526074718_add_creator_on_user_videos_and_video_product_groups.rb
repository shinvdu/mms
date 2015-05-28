class AddCreatorOnUserVideosAndVideoProductGroups < ActiveRecord::Migration
  def change
    add_column :user_videos, :creator_id, :integer, :null => false
    add_column :video_product_groups, :creator_id, :integer, :null => false
  end
end
