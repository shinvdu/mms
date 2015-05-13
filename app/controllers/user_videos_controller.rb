class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :generate_publish_strategy, :only => [:index, :new, :show]

  def index
    @user_videos = UserVideo.where(owner_id: current_user.uid).order('id desc').page(params[:page])
  end

  def new
  end

  def show
    @user_video = UserVideo.find(params[:id])
  end

  def edit
    @user_video = UserVideo.find(params[:id])
  end

  def update
    @user_video = UserVideo.find(params[:id])

    respond_to do |format|
      if @user_video.save
        format.html { redirect_to @user_video, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :updated, location: @user_video }
      else
        format.html { render :new }
        format.json { render json: @user_video.errors, status: :unprocessable_entity }
      end
    end

  end

  def create
    video = user_video_params[:video]
    video_name = user_video_params[:video_name].strip
    publish_strategy = user_video_params[:publish_strategy].to_i
    default_transcoding_strategy = user_video_params[:default_transcoding_strategy].to_i

    if video.blank?
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
      return
    end
    user_video = UserVideo.new(:owner => current_user,
                               :video_name => video_name,
                               :publish_strategy => publish_strategy,
                               :default_transcoding_strategy_id => default_transcoding_strategy
    ).set_video(video)
    user_video.save!
    user_video.delay.publish_by_strategy(publish_strategy,
                                         TranscodingStrategy.find(default_transcoding_strategy))

    respond_to do |format|
      format.html do
        redirect_to video_product_groups_path
      end
      format.json { render :json => 'succeed' }
    end
  end

  def republish
    user_video = UserVideo.find(params[:id])
    if [UserVideo::PUBLISH_STRATEGY::PACKAGE, UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH,
        UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT].include? republish_params[:publish_strategy].to_i
      user_video.delay.publish_by_strategy(republish_params[:publish_strategy].to_i,
                                           TranscodingStrategy.find(republish_params[:transcoding_strategy]))
    end
    redirect_to user_video_path
  end

  def destroy
    # user_video = UserVideo.find(params[:id])
    # user_video.destroy
    redirect_to user_videos_path
  end

  def generate_publish_strategy
    @publish_strategy = {
        '等待编辑' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT,
        '转码后发布' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH,
        '封装为mp4直接发布' => UserVideo::PUBLISH_STRATEGY::PACKAGE,
    }
  end

  def republish_params
    params.require(:republish).permit(:publish_strategy, :transcoding_strategy)
  end

  def user_video_params
    params.require(:user_video).permit(:video_name, :video, :players, :compose_strategy, :default_transcoding_strategy, :publish_strategy)
  end
end
