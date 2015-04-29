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
		con = controller.controller_name

		controller = {
			:home => :home,
			:user_videos => :video,
			:transcodings => :video,
			:transcoding_strategies => :video,
			:strategies => :ad,
			:resources => :ad,
			:players => :player,
			:logos => :player,
			:user => :admin,
		}
		return true if item == controller[con.to_sym]
	end

end
