class VideoProductGroupsController < ApplicationController
  before_action :authenticate_account!, :check_login

  def index
    @video_product_groups = VideoProductGroup.where(:owner => current_user).order('id desc').page(params[:page])
  end

  def show
    @video_product_group = VideoProductGroup.find(params[:id])
  end

  def create
    compose_strategy = product_data_params[:compose_strategy]
    transcoding_strategy_id = product_data_params[:transcoding_strategy_id]
    name = product_data_params[:name].strip
    player_id = product_data_params[:player_id].to_i

    cut_points = JSON.parse(compose_strategy)
    unless cut_points.present?
      respond_to do |format|
        format.html do
          notice_error '至少提交一段视频剪辑'
          redirect_referrer_or_default
        end
        format.json { render :json => 'no transcoding strategy selected', :status => 400 }
      end
      return
    end

    user_video_ids = cut_points.map { |cp| cp['user_video_id'] }
    user_videos = UserVideo.where(:owner => current_user).find(user_video_ids)
    user_videos.each do |uv|
      unless uv.present? && uv.GOT_LOW_RATE? && uv.EDITABLE?
        respond_to do |format|
          format.html { redirect_to user_videos_path }
          format.json { render :json => 'fail' }
        end
        return
      end
    end
    user_video = user_videos.first if user_videos.one?
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
                                                   :owner => current_user,
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
