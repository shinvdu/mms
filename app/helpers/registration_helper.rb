module RegistrationHelper
  def setup_user_info(user_info)
    user_info.build_account unless user_info.account
    user_info
  end
end
