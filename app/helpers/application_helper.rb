module ApplicationHelper
	def render_page_title
		site_name = Settings.title
		title = @page_title ? "#{@page_title} | #{site_name} " : site_name rescue "SITE_NAME"
		content_tag("title", title, nil, false)
	end
	
	def notice_message
		flash_messages = []
		right_close = '<div class="btn-icon l-right"><i class="fa fa-times-circle-o"></i></div>'
		flash.each do |type, message|
			type = :success if type.to_sym == :notice
			text = content_tag(:div,    :class => "alert alert-#{type} clearfix") do |i|
				 [message, content_tag(:div, :class => 'btn-icon l-right') do |i|
					content_tag(:i, :class => 'fa fa-times-circle-o') do |i|
					end
				end].join.html_safe
			end
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
			:video_product_groups => :video,
			:transcoding_strategies => :video,
			:strategies => :ad,
			:resources => :ad,
			:players => :player,
			:logos => :player,
			:user => :admin,
		}
		return true if item == controller[con.to_sym]
	end

	def javascript(*js_files)
		content_for(:head_js) { javascript_include_tag(*js_files) }
	end

	def style(*css_files)
		content_for(:head_css) { stylesheet_link_tag(*css_files) }
	end

	def upload_server
		Settings.server.upload_server.to_a.sample(1).first.second['address'] + uploads_user_videos_path
	end
	def video_server
		Settings.server.video_server.to_a.sample(1).first.second['address']  
	end

end
