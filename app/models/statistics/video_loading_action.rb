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

class Statistics::VideoLoadingAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :video_detail
end
