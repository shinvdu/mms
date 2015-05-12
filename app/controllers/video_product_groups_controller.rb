class VideoProductGroupsController < ApplicationController
  before_action :authenticate_account!, :check_login

  def index
    @video_product_groups = VideoProductGroup.where(:owner => current_user).order('id desc').page(params[:page])
  end

  def show
    @video_product_group = VideoProductGroup.find(params[:id])
  end

  def create
    user_video_id = product_data_params[:user_video_id].to_i
    compose_strategy = product_data_params[:compose_strategy]
    transcoding_strategy_id = product_data_params[:transcoding_strategy_id]
    name = product_data_params[:name].strip
    player_id = product_data_params[:player_id].to_i

    user_video = UserVideo.find(user_video_id)
    unless user_video.present? && user_video.GOT_LOW_RATE? && user_video.EDITABLE?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'fail' }
      end
      return
    end

    cut_points = JSON.parse(compose_strategy)
    video_cut_points = VideoCutPoint.create_by_user(cut_points)

    strategy = TranscodingStrategy.find(transcoding_strategy_id)
    player = Player.find(player_id)
    if strategy.nil? || player.nil?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'no transcoding strategy selected' }
      end
      return
    end
    video_product_group = VideoProductGroup.create(:name => name,
                                                   :user_video => user_video,
                                                   :owner => user_video.owner,
                                                   :player => player,
                                                   :transcoding_strategy => strategy)
    video_product_group.create_fragments(video_cut_points)
    video_product_group.delay.create_products_from_mkv

    respond_to do |format|
      format.html { redirect_to video_product_groups_path }
      format.json { render :json => 'succeed' }
    end
  end

  def download
    send_file VideoProductGroup.find(params[:id]).get_m3u8_file_path
  end

  def product_data_params
    params.require(:product_data).permit(:user_video_id, :name, :compose_strategy, :transcoding_strategy_id, :player_id)
  end
end
