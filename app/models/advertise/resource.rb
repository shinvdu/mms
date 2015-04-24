class Advertise::Resource < ActiveRecord::Base
  belongs_to :user
  mount_uploader :uri, AdResourceUploader
end
