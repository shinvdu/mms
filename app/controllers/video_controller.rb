class VideoController < ApplicationController
  def show
    @video_group = VideoProductGroup.find params[:id]
    if @video_group.FINISHED? && @video_group.ACCEPTED?
  	# @id = params[:id]
  	@video_products = @video_group.video_products
  	@videos = []
  	(@video_products.count > 0 ) && @video_products.each do |video|
  		@videos << video.video_detail
  	end
  	@src = []
  	@videos.each do |video|
  		@src << {
  			:type => "video/mp4",
  			:src  =>  video.get_full_url,
  			'data-res' => 'HD'
  		}
  	end
  end
end

def iframe

end

end
