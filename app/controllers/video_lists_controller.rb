class VideoListsController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :set_new_video_list, only: [:index, :show]
  before_action :set_video_lists, only: [:index, :show, :create]
  before_action :set_video_list, only: [:show, :edit, :add_user_video_to]
  before_action :set_nolist_user_videos, only: [:show]

  def index
  end

  def show
    respond_to do |format|
      format.html { render :index }
      format.json { render :show }
    end
  end

  def create
    @video_list = VideoList.new(new_video_list_params)
    @video_list.owner = current_user

    respond_to do |format|
      if @video_list.save
        format.html { redirect_to @video_list, notice: 'New List is successfully created.' }
        format.json { render :show, status: :created, location: @video_list }
      else
        format.html { render :index }
        format.json { render json: @video_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_user_video_to
    redirect_to @video_list
  end

  private

  def set_video_lists
    @video_lists = VideoList.where(:owner => current_user)
  end

  def set_video_list
    @video_list = VideoList.find params[:id]
  end

  def set_new_video_list
    @new_video_list = VideoList.new
  end

  def set_nolist_user_videos
    @nolist_user_videos = UserVideo
                              .where(:owner => current_user)
                              .joins('LEFT JOIN video_list_links ON user_videos.id=video_list_links.user_video_id')
                              .where(:video_list_links => {:id => nil})
  end

  def video_list_params
    params.require(:video_list).permit(:name)
  end

  def new_video_list_params
    params.require(:video_list).permit(:name)
  end
end
