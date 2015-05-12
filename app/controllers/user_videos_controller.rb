class UserVideosController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :generate_publish_strategy, :only => [:index, :new, :show]

  def index
    @user_videos = UserVideo.where(owner_id: current_user.uid).page(params[:page])
  end

  def new
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
    user_video.delay.publish_by_strategy(user_video_params[:publish_strategy].to_i,
                                         TranscodingStrategy.find(user_video_params[:default_transcoding_strategy]))

    respond_to do |format|
      format.html { redirect_to video_product_groups_path }
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
        '编辑后发布' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_EDIT,
        '转码后发布' => UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH,
        '封装为mkv直接发布' => UserVideo::PUBLISH_STRATEGY::PACKAGE,
    }
  end

  def republish_params
    params.require(:republish).permit(:publish_strategy, :transcoding_strategy)
  end

  def user_video_params
    params.require(:user_video).permit(:video_name, :video, :default_transcoding_strategy, :publish_strategy)
  end
end
