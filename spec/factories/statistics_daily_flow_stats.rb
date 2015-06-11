FactoryGirl.define do
  factory :statistics_daily_flow_stat, :class => 'Statistics::DailyFlowStat' do
    user nil
date "2015-06-01"
amount 1
  end

end
