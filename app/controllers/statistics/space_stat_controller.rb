class Statistics::SpaceStatController < ApplicationController
  before_action :set_user, :only => :show

  def show
    num = (params[:days] || 1).to_i
    @stats = @user.daily_space_stats
    @stats = @stats.first(num) if num > 0
    @stats_json = @stats.map do |stat|
      {:date => stat.date,
       :user_video_amount => stat.user_video_amount,
       :mkv_video_amount => stat.mkv_video_amount,
       :product_amount => stat.product_amount
      }
    end.to_json
    respond_to do |format|
      format.html
      format.json { render @stats }
    end
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
