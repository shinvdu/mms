FactoryGirl.define do
	factory :account do
		username "silas"
		email "18217401108@163.com"
		password "12345678"
		password_confirmation "12345678"
		association :user
	end

	factory :user do
		nickname "silas"
	end

end
