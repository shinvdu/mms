class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login

  def index
    @user_videos = UserVideo.where(owner_id: current_user.uid).page(params[:page])
  end

  def new
    @publish_strategy = {
        '封装为mkv直接发布' => UserVideo::PUBLISH_STRATEGY::PACKAGE,
        '转码后发布' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH,
        '转码并编辑' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT
    }
  end

  def show
    @user_video = UserVideo.find(params[:id])
  end

  def create
    if user_video_params[:video].blank?
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
      return
    end
    user_video = UserVideo.new(:owner => current_user,
                               :video_name => user_video_params[:video_name],
                               :publish_strategy => user_video_params[:publish_strategy],
                               :default_transcoding_strategy_id => user_video_params[:default_transcoding_strategy]
    ).set_video(user_video_params[:video])
    user_video.save!

    respond_to do |format|
      format.html { redirect_to user_videos_path }
      format.json { render :json => 'succeed' }
    end
  end

  def destroy
    user_video = UserVideo.find(params[:id])
    user_video.destroy
    redirect_to user_videos_path
  end

  def user_video_params
    params.require(:user_video).permit(:video_name, :video, :default_transcoding_strategy, :publish_strategy)
  end
end
