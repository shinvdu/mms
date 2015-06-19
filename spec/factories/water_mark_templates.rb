# == Schema Information
#
# Table name: water_mark_templates
#
#  id                            :integer          not null, primary key
#  owner_id                      :integer
#  creator_id                    :integer
#  name                          :string(255)
#  width                         :integer
#  height                        :integer
#  refer_pos                     :string(255)
#  text                          :string(255)
#  img                           :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  aliyun_water_mark_template_id :string(255)
#  status                        :integer          default(10)
#  font_size                     :integer
#  transparency                  :integer
#

FactoryGirl.define do
  factory :water_mark_template do
    owner_id 1
creator_id 1
name "MyString"
width 1
height 1
refer_pos "MyString"
text "MyString"
img "MyString"
  end

end
