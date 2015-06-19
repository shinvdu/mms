class VideoController < ApplicationController
  before_action :explode_session_id

  def show
    @video_group = VideoProductGroup.where(show_id: params[:id]).first
    if not @video_group.ACCEPTED?
      render html: '视频还没通过审核'
      return
    end
    if @video_group.FINISHED? && 
      @video_products = @video_group.video_products
      @src = []
      @video_products.each do |product|
        @src << {
            :type => "video/#{(product.transcoding && product.transcoding.container) ?  product.transcoding.container : 'mp4'}",
            :src => ['/video_paths?', "video_id=#{@video_group.show_id}", "&video_product_id=#{product.id}"].join(''),
            'data-res' => "#{product.check_quanity}",
        }
      end
    else
      notice_error '没有这个视频'
      redirect_to :root
      return
    end
  end

  def iframe
     headers['X-Frame-Options'] = 'GOFORIT'
     if not @video_group.ACCEPTED?
      render html: '视频还没通过审核'
      return
    end
    @video_group = VideoProductGroup.where(show_id: params[:id]).first
    if @video_group.FINISHED?
      @video_products = @video_group.video_products
      @src = []
      @video_products.each do |product|
        @src << {
          :type => "video/#{(product.transcoding && product.transcoding.container) ?  product.transcoding.container : 'mp4'}",
          :src => ['/video_paths?', "video_id=#{@video_group.show_id}", "&video_product_id=#{product.id}"].join(''),
          'data-res' => "#{product.check_quanity}",
        }
      end
    else
      render html: '没有这个视频'
      return
    end
    render layout: 'player'
  end

  def path
    # params: video_id, signture, video_product_id
    video_group_id = params[:video_id]
    signature = params[:signature]
    # logger.info(signature)
    video_product_id = params[:video_product_id]
    session_id = session[:session_id]
    #  服务端的签名
    string_to_sign = [session_id, video_group_id, Settings.video_salt].join('#')
    # logger.info(string_to_sign)
    server_signature = Digest::SHA1.hexdigest(string_to_sign)
    # logger.info(server_signature)
    if signature == server_signature
      video_product = VideoProductGroup.where(show_id: video_group_id).first.video_products.where(id: video_product_id).first
      video_detail = video_product.video_detail
      redirect_to video_detail.get_full_url
      return
      # else
      #   notice_error '解析视频地址失败'
    end

  end

  def preview
       id = params[:id]
       @width = Settings.default_player.width
       @height = Settings.default_player.height
       @video_product_group = VideoProductGroup.where(show_id: id).first
       if not @video_product_group
          render html: '没有这个视频'
       else
          render :layout => false
       end
  end

    def code
       id = params[:id]
       @width = Settings.default_player.width
       @height = Settings.default_player.height
       @video_product_group = VideoProductGroup.where(show_id: id).first
       if not @video_product_group
          render html: '没有这个视频'
       else
          render  :layout => false
       end
  end


  protected

  def explode_session_id
    cookies[:wgcloud_id] = session[:session_id]
    cookies[:video_salt] = Settings.video_salt
  end

end
