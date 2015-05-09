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

  def format_file_size(size)
    size *= 1.0
    unit = 'B'
    if size > 1024
      size = size / 1024
      unit = 'K'
    end
    if size > 1024
      size = size / 1024
      unit = 'M'
    end
    if size > 1024
      size = size / 1024
      unit = 'G'
    end
    "#{size.round(2)}#{unit}"
  end
end
