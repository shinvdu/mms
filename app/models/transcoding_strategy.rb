class TranscodingStrategy < ActiveRecord::Base
  belongs_to :user
  has_many :transcoding_strategy_relationship
end
