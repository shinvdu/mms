class TagsRelationship < ActiveRecord::Base
  belongs_to :tag
  belongs_to :user
  belongs_to :user_video
end
