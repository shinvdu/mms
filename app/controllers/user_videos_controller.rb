class UserVideosController < ApplicationController
  before_action :authenticate_user!, :check_login
  def index
    @videos = current_user.user_videos
  end

  def new

  end

  def create
    videoDetail = VideoDetail.new
    videoDetail.processUploadedFile(params[:fileData][:video])
    videoDetail.videoName = params[:fileData][:videoName]
    videoDetail.save!

    userVideo = UserVideo.new(:owner => current_user,
                              :original_video => videoDetail)
    userVideo.save!
    videoDetail.user_video = userVideo
    videoDetail.save!

    render :json => 'succeed'
  end


end
