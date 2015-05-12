class AddUuidOnVideoProductGroups < ActiveRecord::Migration
  require 'uuidtools'

  def change
    add_column :video_product_groups, :uuid, :string
    VideoProductGroup.reset_column_information
    VideoProductGroup.where(:uuid => nil).each do |g|
      g.uuid = UUIDTools::UUID.random_create.to_s
      g.save!
    end
  end
end
