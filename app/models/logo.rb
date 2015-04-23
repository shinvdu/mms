class Logo < ActiveRecord::Base
  belongs_to :user
  has_many :player
  
  mount_uploader :uri, LogoUploader
end
