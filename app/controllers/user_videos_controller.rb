class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login

  def index
    @user_videos = UserVideo.where(owner_id: current_user.uid)
  end

  def new

  end

  def show
    @user_video = UserVideo.find(params[:id])
  end

  def create
    if params[:file_data].blank?
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
      return
    end
    video_name = params[:file_data][:video_name]
    video = params[:file_data][:video]
    user_video = UserVideo.new(current_user, video_name, video)
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

  def admin
    @user_videos = UserVideo.where(owner_id: current_user.uid)
    render 'user_videos/index'
  end

end
