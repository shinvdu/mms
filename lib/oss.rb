module OSS 
  def private_signed_url()
    url = self.get_full_url
    expire = Settings.aliyun.oss.private_video_signed_duration.to_i.hours.from_now.to_i
    string_to_sign = "GET\n\n\n#{expire}\n/#{self.bucket}/#{self.uri}"
    digest = OpenSSL::Digest.new('sha1')
    h = OpenSSL::HMAC.digest(digest, Settings.aliyun.access_key, string_to_sign)
    h = Base64.encode64(h).strip()
    h = percent_encode(h)
    url << "?Expires=#{expire}&OSSAccessKeyId=#{Settings.aliyun.access_id}&Signature=#{h}"
  end
end
