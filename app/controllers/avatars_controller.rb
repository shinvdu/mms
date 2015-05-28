class AvatarsController < ApplicationController
  before_action :authenticate_account!
  def create
    @avatar = Avatar.new
    @avatar.image = params[:avatar][:image]
    if @avatar.valid?
      # user = User.find( params[:user_id] )
      current_user.avatar.try(:destroy!)
      @avatar.user = current_user
      @avatar.save!
      redirect_to '/avatars/new'
    end
  end

  def new
    if current_user.avatar
       @avatar = current_user.avatar
    else
      @avatar = Avatar.new 
    end
  end

end
