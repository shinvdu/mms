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

end
