class VideoProductGroupsController < ApplicationController
  def create
    user_video = UserVideo.find(product_data_params[:user_video_id])
    if !user_video.GOT_LOW_RATE?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'fail' }
      end
      return
    end

    cut_points = JSON.parse(product_data_params[:cut_points])
    video_cut_points = VideoCutPoint.create(cut_points)
    video_cut_points.each do |cp|
      cp.user_created = true
      cp.save!
    end

    strategy = user_video.default_transcoding_strategy
    if (strategy.nil?)
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'no default transcoding strategy selected' }
      end
      return
    end
    video_product_group = VideoProductGroup.create(:name => product_data_params[:name].strip,  :user_video => user_video, :transcoding_strategy => strategy)
    video_product_group.create_fragments(video_cut_points)
    video_product_group.create_products

    respond_to do |format|
      format.html { redirect_to user_videos_path }
      format.json { render :json => 'succeed' }
    end
  end

  def download
    send_file VideoProductGroup.find(params[:id]).get_m3u8_file_path
  end

  def product_data_params
    params.require(:product_data).permit(:user_video_id, :name, :cut_points)
  end
end
