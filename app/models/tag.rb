class Tag < ActiveRecord::Base
  has_many :tags_relationship
  belongs_to :user
end
