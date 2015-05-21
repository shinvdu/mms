class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :generate_publish_strategy, :only => [:index, :new, :show]
  before_action :set_user_video, only: [:show, :edit, :clip, :republish, :update, :destroy]

  def index
    @user_videos = UserVideo.where(owner_id: current_user.uid).order('id desc').page(params[:page])
  end

  def new
  end

  def show
  end

  def edit
  end

  def clip
  end

  def create
    video = user_video_params[:video]
    video_name = user_video_params[:video_name].strip
    publish_strategy = user_video_params[:publish_strategy].to_i
    default_transcoding_strategy = user_video_params[:default_transcoding_strategy]
    default_transcoding_strategy = default_transcoding_strategy.to_i if default_transcoding_strategy

    if video.blank?
      session[:return_to] ||= request.referer
      notice_error '必须选择视频'
      redirect_to session.delete(:return_to)
      return
    end
    @user_video = UserVideo.new(:owner => current_user,
                                :video_name => video_name
    ).set_video(video)
    unless @user_video.save
      notice_error '输入视频名称'
      redirect_to session.delete(:return_to)
      return
    end
    case publish_strategy
      when UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
        @user_video.delay.publish_by_strategy(publish_strategy,
                                              TranscodingStrategy.find(default_transcoding_strategy))
      when UserVideo::PUBLISH_STRATEGY::PACKAGE
        @user_video.delay.publish_by_strategy(publish_strategy, nil)
    end

    respond_to do |format|
      format.html do
        redirect_to video_product_groups_path
      end
      format.json { render :json => 'succeed' }
    end
  end

  def update
    respond_to do |format|
      if @user_video.update(user_video_params)
        format.html { render :show, notice: 'Video is successfully updated.' }
        format.json { render :show, status: :ok, location: @user_video }
      else
        format.html { render :edit }
        format.json { render json: @user_video.errors, status: :unprocessable_entity }
      end
    end
  end

  def republish
    @user_video = UserVideo.find(params[:id])
    if [UserVideo::PUBLISH_STRATEGY::PACKAGE, UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH,
        UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT].include? republish_params[:publish_strategy].to_i
      @user_video.delay.publish_by_strategy(republish_params[:publish_strategy].to_i,
                                            TranscodingStrategy.find(republish_params[:transcoding_strategy]))
    end
    redirect_to user_video_path
  end

  def destroy
    # user_video = UserVideo.find(params[:id])
    # user_video.destroy
    redirect_to user_videos_path
  end

  private
  def set_user_video
    @user_video = UserVideo.find(params[:id])
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
    params.require(:user_video).permit(:video_name, :description, :video, :players, :compose_strategy, :default_transcoding_strategy, :publish_strategy)
  end
end
