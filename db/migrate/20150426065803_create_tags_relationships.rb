class CreateTagsRelationships < ActiveRecord::Migration
  def change
    create_table :tags_relationships do |t|
      t.integer :tag_id
      t.integer :user_video_id

      t.timestamps null: false
    end
  end
end
