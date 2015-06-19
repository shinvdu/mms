class CacheUserVideoForm < CacheForm
  def init_params(p)
    @user = p[:user]
    @video = p[:video]
    data = JSON.parse self.params
    @video_name = data['video_name'].strip
    @publish_strategy = data['publish_strategy'].to_i
    @video_list_id = data['video_list_id'].to_i
    default_transcoding_strategy = data['default_transcoding_strategy']
    if @publish_strategy == UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
      @transcoding_strategy = TranscodingStrategy.find(default_transcoding_strategy)
    end
  end

  def process_data
    raise '请输入视频名称' if @video_name.blank?
    raise '必须选择视频' if @video.blank?
    transaction do
      @user_video = UserVideo.new(:owner => @user.owner,
                                  :creator => @user,
                                  :video_name => @video_name)
      @user_video.update_video_list! @video_list_id
      @user_video.set_video_and_publish(@video, @publish_strategy, @transcoding_strategy)
      @user_video.save!
    end
  end
end
