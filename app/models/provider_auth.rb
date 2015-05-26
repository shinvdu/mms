class ProviderAuth < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :provider_uid, :provider
	validates_uniqueness_of :provider_uid, :scope => :provider

	def self.find_for_oauth(auth)
		find_or_create_by(provider_uid: auth.uid, provider: auth.provider)
	end
end
