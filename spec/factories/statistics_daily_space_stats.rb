# == Schema Information
#
# Table name: statistics_daily_space_stats
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  date              :date
#  user_video_amount :integer
#  mkv_video_amount  :integer
#  product_amount    :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :statistics_daily_space_stat, :class => 'Statistics::DailySpaceStat' do
    user nil
date "2015-06-01"
user_video_amount 1
mkv_video_amount 1
product_amount 1
  end

end
