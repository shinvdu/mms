module ApplicationHelper
	def render_page_title
		site_name = Settings.title
		title = @page_title ? "#{@page_title} | #{site_name} " : site_name rescue "SITE_NAME"
		content_tag("title", title, nil, false)
	end
	
	def notice_message
		flash_messages = []
		flash.each do |type, message|
			 type = :success if type.to_sym == :notice
			text = content_tag(:div, message, :class => "alert alert-#{type}")
			flash_messages << text if message
		  end
		  flash_messages.join("\n").html_safe
	end

	def current_user
		@current_user
	end

	def top_menu_active(item)
		path = request.path
		menu = {
			:'/' => :home,

			:'/user_videos/index' => :video,

			:'/advertise/strategies' => :ad,

			:'/players' => :player,

			:'/admin' => :admin
		}
		return true if item == menu[path.to_sym]
	end

end
