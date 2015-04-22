class HomeController < ApplicationController
	before_action :authenticate_account!
	before_action :authenticate_user!
	def index
  	# notice_success 'just fot est'
  	
	  end
end
