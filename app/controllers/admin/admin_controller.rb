class Admin::AdminController < ApplicationController
  def index
    redirect_to admin_users_path
  end
end
