# == Schema Information
#
# Table name: statistics_daily_flow_stats
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  date       :date
#  amount     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :statistics_daily_flow_stat, :class => 'Statistics::DailyFlowStat' do
    user nil
date "2015-06-01"
amount 1
  end

end
