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

require 'rails_helper'

RSpec.describe Statistics::VideoLoadingAction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
