class Statistics::DailyFlowStat < ActiveRecord::Base
  default_scope { order('date DESC, created_at DESC') }
  belongs_to :user
end
