class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login
  def index
    @videos = current_user.user_videos
  end

  def new

  end

  def show
    @user_video = UserVideo.find(params[:id])
  end

  def create
    userVideo = UserVideo.new(current_user, params[:fileData][:videoName], params[:fileData][:video])
    userVideo.save!

    respond_to do |format|
      format.html {redirect_to user_videos_path}
      format.json { render :json => 'succeed'}
    end
  end

  def destroy
    userVideo = UserVideo.find(params[:id])
    userVideo.destroy
    redirect_to user_videos_path
  end

end
