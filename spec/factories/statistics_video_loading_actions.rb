# == Schema Information
#
# Table name: statistics_video_loading_actions
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  video_detail_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :statistics_video_loading_action, :class => 'Statistics::VideoLoadingAction' do
    user nil
video_detail nil
  end

end
