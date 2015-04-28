class VideoProductGroupsController < ApplicationController
  def create
    user_video = UserVideo.find(params[:user_video_id])
    if !user_video.GOT_LOW_RATE?
      respond_to do |format|
        format.html { redirect_to user_videos_path }
        format.json { render :json => 'fail' }
      end
      return
    end

    cut_points = JSON.parse(params[:product_data][:cut_points])
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
    video_product_group = VideoProductGroup.create(:user_video => user_video, :transcoding_strategy => strategy)
    video_product_group.create_fragments(video_cut_points)
    video_product_group.create_products(strategy.transcodings)

    respond_to do |format|
      format.html { redirect_to user_videos_path }
      format.json { render :json => 'succeed' }
    end
  end
end
