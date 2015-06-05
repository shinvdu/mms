class Settings < Settingslogic
	source "#{Rails.root}/config/application.yml"
	namespace Rails.env

	if File.exist?("#{Rails.root}/config/wgconfig.yml")
		# logger.info '===> Local application configuration file loaded.'
		instance.deep_merge!(Settings.new("#{Rails.root}/config/wgconfig.yml"))  
	else
		# logger.error '===> Local application configuration file no found.'
	end
end