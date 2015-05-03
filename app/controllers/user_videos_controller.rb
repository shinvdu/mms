class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login

  def index
    @user_videos = UserVideo.where(owner_id: current_user.uid).page(params[:page])
  end

  def new
    @strategy = []
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
    video_name = user_video_params[:video_name]
    video = user_video_params[:video]
    user_video = UserVideo.new.set_by_video(current_user, video_name, video)
    user_video.default_transcoding_strategy_id = user_video_params[:default_transcoding_strategy]
    user_video.save!
    video.close

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
    params.require(:user_video).permit(:video_name, :video, :default_transcoding_strategy)
  end
end
