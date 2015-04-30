class VideoProductsController < ApplicationController
  def download
    send_file VideoProduct.find(params[:id]).get_m3u8_file_path
  end
end
