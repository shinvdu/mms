FactoryGirl.define do
	factory :provider_auth do
		user_id 1
		account_id 1
		provider_uid "MyString"
		provider "MyString"
		status true
	end

end
