class TranscodingStrategyRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :transcoding
  belongs_to :transcoding_tractegy
end
