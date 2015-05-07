class VideoProductGroupCheckStatusController < ApplicationController
  before_action :authenticate_account!, :only_admin

  def check
    video_product_group = VideoProductGroup.find(params[:id])
    video_product_group.check(current_user, params[:check_result])
    redirect_referrer_or_default
  end
end
