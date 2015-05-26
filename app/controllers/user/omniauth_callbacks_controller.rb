class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

   #skip CSRF on create.
   skip_before_filter :verify_authenticity_token
   
   def all
    # debugger
    account = Account.from_omniauth(request.env["omniauth.auth"])
    if account.persisted?
      sign_in_and_redirect account
      notice_success '登录成功'
    else
      session["devise.account_attributes"] = account.attributes
      redirect_to new_account_registration_url
    end
  end
  
  alias_method :tqq, :all
  alias_method :douban, :all
  alias_method :weibo, :all

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
