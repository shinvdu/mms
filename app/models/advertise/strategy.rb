class Advertise::Strategy < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
end
