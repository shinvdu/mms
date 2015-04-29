class Admin::UserController < ApplicationController
	def users
		@users  = User.page(params[:page])
	end
end
