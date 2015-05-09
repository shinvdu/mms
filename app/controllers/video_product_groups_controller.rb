class VideoProductGroupsController < ApplicationController
  before_action :authenticate_account!, :check_login

  def create
    user_video = UserVideo.find(product_data_params[:user_video_id])
    unless user_video.present? && user_video.GOT_LOW_RATE? && user_video.EDITABLE?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'fail' }
      end
      return
    end

    cut_points = JSON.parse(product_data_params[:cut_points])
    video_cut_points = VideoCutPoint.create_by_user(cut_points)

    strategy = product_data_params[:select_strategy] ?
        TranscodingStrategy.find(product_data_params[:strategy_id]) : user_video.default_transcoding_strategy
    if strategy.nil?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'no transcoding strategy selected' }
      end
      return
    end
    video_product_group = VideoProductGroup.create(:name => product_data_params[:name].strip,
                                                   :user_video => user_video,
                                                   :owner => user_video.owner,
                                                   :transcoding_strategy => strategy)
    video_product_group.create_fragments(video_cut_points)
    video_product_group.delay.create_products_from_mkv

    respond_to do |format|
      format.html { redirect_to user_videos_path }
      format.json { render :json => 'succeed' }
    end
  end

  def download
    send_file VideoProductGroup.find(params[:id]).get_m3u8_file_path
  end

  def product_data_params
    params.require(:product_data).permit(:user_video_id, :name, :cut_points, :strategy_id, :select_strategy)
  end
end
