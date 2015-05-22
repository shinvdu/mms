class User::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  def new
    super
  end

  # POST /resource/password
  def create
    super
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, params[:reset_password_token])
    user = Account.where(reset_password_token: reset_password_token).first
    # debugger
    if user.nil? || !(user.reset_password_sent_at)
      notice_error '您己经使用过这个链接，如果您需要修改密码，请再次请求。'
      redirect_to new_password_path(resource_name)
      return
    end
  end

  # PUT /resource/password
  def update
    super
  end

  protected

  def after_resetting_password_path_for(resource)
    super(resource)
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    super(resource_name)
  end
end
