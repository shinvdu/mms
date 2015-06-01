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

class Statistics::DailySpaceStat < ActiveRecord::Base
  belongs_to :user
end
