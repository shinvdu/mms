class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :generate_publish_strategy, :only => [:index, :new, :show]
  before_action :set_user_video, only: [:show, :edit, :clip, :republish, :update, :destroy, :update_video_list, :remove_video_list]

  def index
    @user_videos = UserVideo.visible(current_user).order('id desc').page(params[:page])
  end

  def new
  end

  def show
  end

  def edit
    @video_lists = VideoList.get_by_user(current_user)
    @video_list_id = @user_video.video_list.id if @user_video.video_list.present?
  end

  def clip
  end

  def clip_existed
    @video_product_group = VideoProductGroup.visible(current_user).find(params[:video_product_group_id])
    raise unless @video_product_group.CREATED?
    @user_video = @video_product_group.user_video
    render :clip
  end

  def create
    video = user_video_params[:video]
    video_name = user_video_params[:video_name].strip
    publish_strategy = user_video_params[:publish_strategy].to_i
    video_list_id = user_video_params[:video_list_id].to_i
    default_transcoding_strategy = user_video_params[:default_transcoding_strategy]
    default_transcoding_strategy = default_transcoding_strategy.to_i if default_transcoding_strategy

    if video.blank?
      session[:return_to] ||= request.referer
      notice_error '必须选择视频'
      redirect_to session.delete(:return_to)
      return
    end
    ActiveRecord::Base.transaction do
      @user_video = UserVideo.new(:owner => current_user.owner,
                                  :creator => current_user,
                                  :video_name => video_name)
      @user_video.update_video_list! video_list_id
      @user_video.set_video(video)
      unless @user_video.save
        notice_error '输入视频名称'
        redirect_to session.delete(:return_to)
        return
      end
    end
    case publish_strategy
      when UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
        @user_video.delay.publish_by_strategy(publish_strategy,
                                              TranscodingStrategy.find(default_transcoding_strategy))
      when UserVideo::PUBLISH_STRATEGY::PACKAGE
        @user_video.delay.publish_by_strategy(publish_strategy, nil)
      when UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT
        # build empty product group
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
    video_list_id = params[:user_video][:video_list_id].to_i if params[:user_video][:video_list_id].present?
    @user_video.update_video_list!(video_list_id)
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

  def update_video_list
    video_list_id = params[:video_list_id].to_i
    @user_video.update_video_list!(video_list_id)
    respond_to do |format|
      format.html { redirect_to video_list_path(video_list_id), notice: 'Video is successfully updated.' }
      format.json { render :show, status: :ok, location: @user_video }
    end
  end

  def remove_video_list
    video_list_id = params[:video_list_id].to_i
    @user_video.remove_video_list!
    respond_to do |format|
      format.html { redirect_to video_list_path(video_list_id), notice: 'Video is successfully updated.' }
      format.json { render :show, status: :ok, location: @user_video }
    end
  end

  def destroy
    # user_video = UserVideo.find(params[:id])
    # user_video.destroy
    redirect_to user_videos_path
  end

  private

  def set_user_video
    @user_video = UserVideo.visible(current_user).find(params[:id])
  end

  def generate_publish_strategy
    @publish_strategy = {
        '等待编辑' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT,
        '转码后发布' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH,
        '封装为mp4直接发布（不使用水印）' => UserVideo::PUBLISH_STRATEGY::PACKAGE,
    }
  end

  def republish_params
    params.require(:republish).permit(:publish_strategy, :transcoding_strategy)
  end

  def user_video_params
    params.require(:user_video).permit(:video_name, :description, :video, :players, :video_list_id, :compose_strategy, :default_transcoding_strategy, :publish_strategy)
  end
end
