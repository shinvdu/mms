class AddTranscodingAndFragToVideoDetail < ActiveRecord::Migration
  def change
    add_column :video_details, :transcoding_id, :integer
    add_column :video_details, :fragment, :boolean, :default => false
  end
end
