class User::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    if current_user.provider_auths && (provider = current_user.provider_auths.where(provider: 'weibo').first)
      begin
        open("https://api.weibo.com/oauth2/revokeoauth2?access_token=#{provider.access_token}").read
      rescue SystemCallError  
        logger.error "user: #{current_user.nickname} 不能清空access_token"
      end
    end
    super
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
