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

class Statistics::DailyLoadingStat < ActiveRecord::Base
  default_scope { order('date DESC, created_at DESC') }
  belongs_to :user
end
