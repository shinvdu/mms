module UserVideosHelper
  include MTSUtils::Core
  def get_url_with_privilege(video_detail)
    url = video_detail.get_full_url
    expire = Time.now.to_i + 1.day.to_i
    string_to_sign = "GET\n\n\n#{expire}\n/#{video_detail.bucket}/#{video_detail.uri}"
    digest = OpenSSL::Digest.new('sha1')
    h = OpenSSL::HMAC.digest(digest, Settings.aliyun.access_key, string_to_sign)
    h = Base64.encode64(h).strip()
    h = percent_encode(h)
    url << "?Expires=#{expire}&OSSAccessKeyId=#{Settings.aliyun.access_id}&Signature=#{h}"
  end
end
