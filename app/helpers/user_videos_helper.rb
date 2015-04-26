module UserVideosHelper
  def make_url(name = nil, user_video)
    if user_video.mini_video.present?
      url = "http://#{Settings.aliyun.oss.host}#{user_video.mini_video.uri}"
      content_tag(:a, name || url, {'href' => url}, nil)
    end
  end
end
