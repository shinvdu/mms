class Admin::AdminController < ApplicationController
  def index
    if can? :access, :user_account
      redirect_to admin_users_path
    elsif can? :access, :own_company
      redirect_to company_path(current_user.company)
    else
      raise
    end
  end
end
