class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
  
  def set_user_id(model, user_id = 'user_id')
    params[model.to_sym][user_id.to_sym] = current_user.uid
  end

  def permission_access(model)
    current_model = instance_variable_get("@#{model.to_s}")
    if @current_user.admin?
      return
    end
    if @current_user.uid != current_model.user_id
      redirect_to :root 
      return
    end
  end
  
  
  # for seo
  def set_seo_meta(title = '', meta_keywords = '', meta_description = '')
    if title.length > 0
      @page_title = "#{title}"
    end
    @meta_keywords = meta_keywords
    @meta_description = meta_description
  end

  # for user can go back
  def store_location
    session[:return_to] = request.original_url
  end

  # back to default
  def redirect_back_or_default(default = nil)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # go to referer
  def redirect_referrer_or_default(default = nil)
    redirect_to(request.referrer || default)
  end

  # add notice message
  def notice_info(msg)
    flash[:info] = msg
  end

  def notice_success(msg)
    flash[:success] = msg
  end

  def notice_warning(msg)
    flash[:warning] = msg
  end

  def notice_error(msg)
    flash[:danger] = msg
  end

  def only_admin
      if @current_user.admin?
        return
      else
        redirect_to :root 
      end
    end


  protected

  def check_login
    redirect_to :root if @current_user.nil?
  end

  def current_user
     @current_user = current_account.user if current_account
  end
end
