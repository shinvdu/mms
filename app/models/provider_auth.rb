class ProviderAuth < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :provider_uid, :provider
	validates_uniqueness_of :provider_uid, :scope => :provider

	def self.find_for_oauth(auth)
		# debugger
		provider_auth = find_or_create_by(provider_uid: auth.uid, provider: auth.provider)
		provider_auth.access_token = auth.credentials.token
		provider_auth.save!
		provider_auth
	end
end

#------------------------------------------------------------------------------
# ProviderAuth
#
# Name         SQL Type             Null    Default Primary
# ------------ -------------------- ------- ------- -------
# id           int(11)              false           true   
# user_id      int(11)              true            false  
# account_id   int(11)              true            false  
# provider_uid varchar(255)         true            false  
# provider     varchar(255)         true            false  
# status       tinyint(1)           true    1       false  
# created_at   datetime             false           false  
# updated_at   datetime             false           false  
# access_token varchar(255)         true            false  
#
#------------------------------------------------------------------------------
