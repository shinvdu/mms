module UserVideosHelper
  def get_preview_path(user_video)
    if user_video.mini_video.present? && user_video.GOT_LOW_RATE?
      "http://#{Settings.aliyun.oss.host}#{user_video.mini_video.uri}"
    end
  end
end
