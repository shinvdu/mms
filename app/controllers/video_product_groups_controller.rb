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
      cp.user_video = user_video
      cp.save!
    end

    video_product_group = VideoProductGroup.create(user_video: user_video)

    video_cut_points.each do |cp, idx|
      VideoFragment.create(video_product_group: video_product_group,
                           video_cut_point: cp,
                           order: idx)
    end

    respond_to do |format|
      format.html { redirect_to user_videos_path }
      format.json { render :json => 'succeed' }
    end
  end
end
