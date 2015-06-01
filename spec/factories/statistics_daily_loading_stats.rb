# == Schema Information
#
# Table name: statistics_daily_loading_stats
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  date       :date
#  amount     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :statistics_daily_loading_stat, :class => 'Statistics::DailyLoadingStat' do
    user nil
date "2015-06-01"
amount 1
  end

end
