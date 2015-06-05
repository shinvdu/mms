class VideoProductGroupsController < ApplicationController
  before_action :authenticate_account!, :check_login
  before_action :set_video_product_group, only: [:clip_existed]

  def index
    arel = VideoProductGroup.arel_table
    @video_product_groups = VideoProductGroup.visible(current_user).order('id desc')
    @name = search_params[:name]
    begin
      @from = Date.parse search_params[:from] if search_params[:from].present?
    rescue
      notice_error('输入时间不正确')
    end
    begin
      @to = Date.parse search_params[:to] if search_params[:to].present?
    rescue
      notice_error('输入时间不正确')
    end
    @video_list_id = search_params[:video_list_id].to_i
    @video_product_groups = @video_product_groups.where(arel[:name].matches("%#{@name}%")) if @name.present?
    @video_product_groups = @video_product_groups.where(arel[:created_at].gteq(@from)) if @from.present?
    @video_product_groups = @video_product_groups.where(arel[:created_at].lteq(@to.tomorrow)) if @to.present?
    @video_product_groups = @video_product_groups.joins(:video_list).where(:video_lists => {:id => @video_list_id}) if @video_list_id > 0
    @video_product_groups = @video_product_groups.page(params[:page])
  end

  def show
    @video_product_group = VideoProductGroup.find(params[:id])
  end

  def create
    begin
      name, video_cut_points, user_video, player, strategy = get_clip_params
    rescue
      return
    end
    ActiveRecord::Base.transaction do
      video_product_group = VideoProductGroup.create(:name => name,
                                                     :user_video => user_video,
                                                     :owner => current_user.owner,
                                                     :creator => current_user,
                                                     :player => player,
                                                     :transcoding_strategy => strategy)
      video_product_group.set_video_list_by_user_video(user_video) if user_video.present?
      video_product_group.create_fragments(video_cut_points)
      video_product_group.delay.create_products_from_mkv
    end

    respond_to do |format|
      format.html { redirect_to video_product_groups_path }
      format.json { render :json => 'succeed' }
    end
  end

  def clip
    begin
      name, video_cut_points, user_video, player, strategy = get_clip_params
    rescue
      return
    end
    video_product_group = VideoProductGroup.visible(current_user)
                              .where(:status => VideoProductGroup::STATUS::CREATED).find(params[:video_product_group][:id])
    video_product_group.transaction do
      video_product_group.name = name
      video_product_group.player = player
      video_product_group.transcoding_strategy = strategy
      video_product_group.status = VideoProductGroup::STATUS::SUBMITTED
      video_product_group.create_fragments(video_cut_points)
      video_product_group.delay.create_products_from_mkv
      video_product_group.save!
    end
    redirect_to video_product_groups_path
  end

  def download
    send_file VideoProductGroup.find(params[:id]).get_m3u8_file_path
  end

  private

  def get_clip_params
    compose_strategy = product_data_params[:compose_strategy]
    transcoding_strategy_id = product_data_params[:transcoding_strategy_id]
    name = product_data_params[:name].strip
    player_id = product_data_params[:player_id].to_i

    cut_points = JSON.parse(compose_strategy)
    unless cut_points.present?
      respond_to do |format|
        format.html do
          notice_error '至少提交一段视频剪辑'
          redirect_referrer_or_default
        end
        format.json { render :json => 'no transcoding strategy selected', :status => 400 }
      end
      raise
    end

    user_video_ids = cut_points.map { |cp| cp['user_video_id'] }
    user_videos = UserVideo.visible(current_user).find(user_video_ids)
    user_videos.each do |uv|
      unless uv.present? && uv.GOT_LOW_RATE? && uv.EDITABLE?
        respond_to do |format|
          format.html { redirect_referrer_or_default }
          format.json { render :json => 'fail' }
        end
        raise
      end
    end
    user_video = user_videos.first if user_videos.one?
    video_cut_points = VideoCutPoint.create_by_user(cut_points)

    strategy = TranscodingStrategy.visible(current_user).find(transcoding_strategy_id)
    player = Player.visible(current_user).find(player_id)
    if strategy.nil? || player.nil?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'no transcoding strategy selected' }
      end
      raise
    end
    return name, video_cut_points, user_video, player, strategy
  end

  def set_video_product_group
    @video_product_group = VideoProductGroup.visible(current_user).find(params[:video_product_group_id])
  end

  def product_data_params
    params.require(:product_data).permit(:user_video_id, :name, :compose_strategy, :transcoding_strategy_id, :player_id)
  end

  def search_params
    params[:search].present? ? params.require(:search).permit(:name, :from, :to, :video_list_id) : {}
  end
end
