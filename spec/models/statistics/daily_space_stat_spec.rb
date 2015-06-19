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

require 'rails_helper'

RSpec.describe Statistics::DailySpaceStat, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
