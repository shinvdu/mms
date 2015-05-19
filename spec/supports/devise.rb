#module ControllerDevise
  def login_user
    before do
      single_login_user
    end
  end

  def single_login_user
    request.env["devise.mapping"] = Devise.mappings[:account]
    @account = FactoryGirl.create(:account)
    sign_in @account
  end

#end
