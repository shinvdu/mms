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

  def build_oss_connection(**opts)
    @opts = {
        :aliyun_access_id => Settings.aliyun.access_id,
        :aliyun_access_key => Settings.aliyun.access_key,
        :aliyun_bucket => Settings.aliyun.oss.public_bucket,
        :aliyun_area => Settings.aliyun.area,
        :aliyun_internal => false,
    }.merge(opts)
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@opts)
  end
end
