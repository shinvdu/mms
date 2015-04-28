class Admin::UserController < ApplicationController
	def users
		@users  = User.all
	end
end
