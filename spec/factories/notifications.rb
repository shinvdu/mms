FactoryGirl.define do
	factory :notification do
		is_read false
		title "MyString"
		target_id 1
		target_type "MyString"
	end
end
