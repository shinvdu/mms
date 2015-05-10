class Advertise::Resource < ActiveRecord::Base
  belongs_to :user
  belongs_to :video_detail, :class_name => 'VideoDetail', :foreign_key => :advertise_resource_id
  mount_uploader :uri, AdResourceUploader
end
