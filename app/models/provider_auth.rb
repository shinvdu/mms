class ProviderAuth < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :uid, :provider
	validates_uniqueness_of :uid, :scope => :provider

	def self.find_for_oauth(auth)
		find_or_create_by(user_id: auth.uid, provider: auth.provider)
	end
end
