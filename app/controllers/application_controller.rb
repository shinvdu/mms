class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

      # for seo 
    def set_seo_meta(title = '',meta_keywords = '', meta_description = '')
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
    def redirect_back_or_default(default)
    	redirect_to(session[:return_to] || default)
    	session[:return_to] = nil
    end

    # go to referer
    def redirect_referrer_or_default(default)
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


  protected

  def current_user
    @current_user
  end

  private

  def authenticate_user!
    :authenticate_account!
    @current_user = current_account.id
  end
end
