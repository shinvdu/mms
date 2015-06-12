class UserVideosController < ApplicationController
  # before_action :authenticate_account!, :check_login
  before_action :generate_publish_strategy, :only => [:index, :new, :show]
  before_action :set_user_video, only: [:show, :edit, :clip, :republish, :update, :destroy, :update_video_list, :remove_video_list]
  skip_before_filter :verify_authenticity_token, :only => [:uploads]

  def index
    @user_videos = UserVideo.visible(current_user).not_deleted.order('id desc').page(params[:page])
  end

  def muti_uploads

  end

  def uploads
    first = params[:files].first if params[:files]
    # debugger
    # first.path  # save file
    # first.original_filename # filename
    # first.content_type
    # first.size

    json_data = { 
      files:
      [
        {
          name: first.original_filename,
          url: "http://url.to/file/or/page",
          thumbnail_url: "http://url.to/thumnail.jpg ",
          type: first.content_type,
          size: first.content_type,
          delete_url: "http://url.to/delete /file/",
          delete_type: "DELETE"
        }
      ]
    }        
    render json: json_data
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
      @user_video.delay(:queue => Settings.job_queue.slow).publish_by_strategy(republish_params[:publish_strategy].to_i,
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
    @user_video.destroy!
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
