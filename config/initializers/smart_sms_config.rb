# encoding: utf-8

SmartSMS.configure do |config|
  config.api_key = Settings.sms.apikey
  config.api_version = :v1
  config.template_id = '2'
  config.template_value = [:code, :company]
  config.page_num = 1
  config.page_size = 20
  config.company = '未谷云'
  config.expires_in = 1.hour
  config.default_interval = 1.day
  config.store_sms_in_local = true
  config.verification_code_algorithm = :simple
end
