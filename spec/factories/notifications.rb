FactoryGirl.define do
	factory :notification do
		is_read false
		title "MyString"
		target_type "UserVideo"
	end
end
