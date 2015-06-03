class VideoController < ApplicationController
  before_action :explode_session_id

  def show
    @video_group = VideoProductGroup.find params[:id]
    if @video_group.FINISHED? && @video_group.ACCEPTED?
  	# @id = params[:id]
  	@video_products = @video_group.video_products
  	# @videos = []
  	# (@video_products.count > 0 ) && @video_products.each do |video|
  	# 	@videos << video.video_detail
  	# end
      host_url = Settings.host_url
  	@src = []
  	@video_products.each do |product|
  		@src << {
  			:type => "video/#{product.transcoding.container}",
  			:src  =>  [host_url, '/video_path?', "video_id=#{@video_group.id}", "&video_product_id=#{product.id}"].join(''),
  			'data-res' => "#{check_quanity(product)}",
  		}
  	end
  end
end

def iframe

end

def video_path 
    # params: video_id = ? 
    # params: signture = ? 
    # params: video_product_id = ? 
    video_group_id =  params[:video_id]
    signature =  params[:signature]
    logger.info(signature)
    video_product_id =  params[:video_product_id]
    session_id = session[:session_id]
    #  服务端的签名
    string_to_sign = [session_id, video_group_id, Settings.video_salt].join('#')
    logger.info(string_to_sign)
    server_signature = Digest::SHA1.hexdigest(string_to_sign)
    logger.info(server_signature)
    if signature == server_signature
      video_product = VideoProduct.where(id: video_product_id).first
      video_detail = video_product.video_detail
      redirect_to video_detail.get_full_url 
      return
    else
      notice_error 'failed'
    end

end

protected

def explode_session_id
  # cookies.delete :wgcloud_id
   session_id  =  session[:session_id]
  # logger.info('---------------------------------------------')
  # debugger
  # logger.info(session_id)
  # logger.info('---------------------------------------------')
  cookies[:wgcloud_id] = session_id 
  # cookies[:session_id] = session[:session_id]
  cookies[:video_salt] = Settings.video_salt
end

def check_quanity(video_product)
    transcoding = video_product.transcoding 
    case transcoding
    when transcoding.width.nil? && transcoding.height.nil?
        video_detail = video_product.video_detail
        quanity_desc = [video_detail.height, 'P'].join('')
    when transcoding.width && transcoding.height.nil?
      quanity_desc = ['H' , transcoding.width].join('')
    when transcoding.width.nil? && transcoding.height
      quanity_desc = [transcoding.height, 'P'].join('')
    end
    return quanity_desc
end
end
