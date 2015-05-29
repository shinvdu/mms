class HomeController < ApplicationController
	before_action :authenticate_account!
	def index
  	# notice_success 'just fot est'
  	# session[:github] = 'jsot for ste'
  	cookies[:github_username] = 'neerajdotname'
	  end
end
