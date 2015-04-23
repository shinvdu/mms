require 'fileutils'

class VideoDetailsController < ApplicationController
  def create
    video_detail = VideoDetail.find(params[:id])
    video = params[:video]
    # TODO setting for temporary uploaded file
    path = Rails.root.join("public/uploads", video_detail.uri)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, 'wb') do |f|
      f.write(video)
    end
    # use delayed_job
    # save video in local
    # async fetch info and upload for (video_detail, video)
    render :json => 'succeed'
  end

  def index

  end
end
