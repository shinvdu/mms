class VideoProductsController < ApplicationController
  def download
    # send_file VideoProduct.find(params[:id]).get_m3u8_file_path
    redirect_to VideoProduct.find(params[:id]).video_detail.get_full_url
  end
end
