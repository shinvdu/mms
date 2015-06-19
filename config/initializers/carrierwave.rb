CarrierWave.configure do |config|
  config.storage           = :aliyun
  config.aliyun_access_id  = Settings.aliyun.access_id
  config.aliyun_access_key = Settings.aliyun.access_key
  # 你需要在 Aliyum OSS 上面提前创建一个 Bucket
  config.aliyun_bucket     = Settings.aliyun.oss.private_bucket
  # 是否使用内部连接，true - 使用 Aliyun 局域网的方式访问  false - 外部网络访问
  config.aliyun_internal   = false
  # 配置存储的地区数据中心，默认: cn-hangzhou
  config.aliyun_area     = Settings.aliyun.area
  # 使用自定义域名，设定此项，carrierwave 返回的 URL 将会用自定义域名
  # 自定于域名请 CNAME 到 you_bucket_name.oss.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
  # config.aliyun_host       = 'http://foo.bar.com'
  # 如果有需要，你可以自己定义上传 host, 比如阿里内部的上传地址和 Aliyun OSS 对外的不同，可以在这里定义，没有需要可以不用配置
  # config.aliyun_upload_host = "http://you_bucket_name.oss.aliyun-inc.com"
end

include MTSUtils::Core
CarrierWave::Storage::Aliyun::Connection.class_eval do
  def get(path)
    path = format_path(path)
    url  = path_to_url(path)
    expire = Time.now.to_i + 1.day.to_i
    string_to_sign = "GET\n\n\n#{expire}\n/#{@aliyun_bucket}/#{path}"
    digest = OpenSSL::Digest.new('sha1')
    h = OpenSSL::HMAC.digest(digest, @aliyun_access_key, string_to_sign)
    h = Base64.encode64(h).strip()
    h = percent_encode(h)
    url << "?Expires=#{expire}&OSSAccessKeyId=#{@aliyun_access_id}&Signature=#{h}"
    # puts Settings.aliyun.access_key, string_to_sign, url
    RestClient.get(url)
  end
end
