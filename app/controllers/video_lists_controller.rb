class VideoListsController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :set_new_video_list, only: [:index, :show]
  before_action :set_video_lists, only: [:index, :show, :create]
  before_action :set_video_list, except: [:index, :create]
  before_action :set_nolist_user_videos, only: [:show]

  def index
  end

  def edit
    @privilege_users = @video_list.privilege_members
  end

  def update
    @video_list.transaction do
      @video_list.name = video_list_params[:name]
      @video_list.save!
      member_ids = (video_list_params[:members] || []).map { |id| id.to_i }
      @video_list.set_privilege_members(member_ids)
      redirect_to @video_list
    end
  end

  def show
    render :index
  end

  def create
    @video_list = VideoList.new(new_video_list_params)
    @video_list.owner = current_user

    if @video_list.save
      redirect_to @video_list, notice: 'New List is successfully created.'
    else
      render :index
    end
  end

  def update_user_video_on
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
    params.require(:video_list).permit(:name, :members => [])
  end

  def new_video_list_params
    params.require(:video_list).permit(:name)
  end
end
