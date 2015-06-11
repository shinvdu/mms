class VideoProductGroupCheckStatusesController < ApplicationController
  before_action :authenticate_account!, :only_admin

  def index
    @video_product_groups = VideoProductGroup.need_check.page(params[:page])
  end

  def update
    authorize! :check, VideoProductGroup
    video_product_group = VideoProductGroup.find(params[:id])
    video_product_group.check(current_user, params[:check_result].to_i)
    redirect_referrer_or_default
  end
end
