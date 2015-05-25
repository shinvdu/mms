require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']

source 'http://ruby.taobao.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'devise'
gem 'devise-encryptable'
# 三方平台 OAuth 验证登陆
gem 'omniauth'
gem 'omniauth-oauth2'

gem 'mysql2'
# YAML配置信息
gem 'settingslogic'
# aliyun OSS
gem 'rest-client'
gem 'carrierwave-aliyun'
gem 'uuidtools'
gem 'mini_magick', '~> 3.8.1'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'kaminari'
gem 'streamio-ffmpeg'
gem 'log4r'
gem 'smart_sms' # 发送短信
gem 'cancancan', '~> 1.10.1'

gem 'unicorn'
gem 'simple_form'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # 自动刷新页面
  gem 'guard-livereload', '~> 2.4', require: false
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'annotate_models'


  # 测试用的
  gem "rspec-rails"
  # 方便生成测试数据
  gem 'factory_girl_rails'
  # 文件改变自动执行测试
  gem 'guard-rspec', require: false
  # 模拟用户的行为进行测试
  gem 'capybara'
  gem 'database_cleaner'

  # gem 'guard-spork'
  # gem 'spork'

  case HOST_OS
  when /darwin/i
    gem 'rb-fsevent'
    gem 'growl'
    gem 'guard-pow'
  when /linux/i
    gem 'libnotify'
    gem 'rb-inotify'
end

end
