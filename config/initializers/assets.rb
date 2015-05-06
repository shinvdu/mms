# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( home.js user_videos.js logos.js players.js tags.js transcoding_strategies.js transcodings.js users.js video_products.js advertise/resources.js  advertise/strategies.js admin/user.js)
Rails.application.config.assets.precompile += %w( home.css user_videos.css logos.css players.css tags.css transcoding_strategies.css transcodings.css users.css video_products.css  advertise/resources.css advertise/strategies.css admin/user.css)
