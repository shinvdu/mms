class UploaderController < ApplicationController
  before_action :authenticate_account!, :check_login, :except => [:upload]
  after_action :cors_set_access_control_headers
  skip_before_filter :verify_authenticity_token, :only => [:upload]
  before_action :verify_one_time_token, :only => [:upload]

  # in main server
  def preupload
    video_name = user_video_params[:video_name].strip
    publish_strategy = user_video_params[:publish_strategy].to_i
    video_list_id = user_video_params[:video_list_id].to_i
    default_transcoding_strategy = user_video_params[:default_transcoding_strategy]
    default_transcoding_strategy = default_transcoding_strategy.to_i if default_transcoding_strategy

    cache_form = CacheForm.new(:user => current_user)
    cache_form.transaction do
      cache_form.params = {
          :video_name => video_name,
          :publish_strategy => publish_strategy,
          :video_list_id => video_list_id,
          :default_transcoding_strategy => default_transcoding_strategy
      }.to_json
      cache_form.save!
      one_time_token = OneTimeToken.do_create(cache_form)
      render json: {:url => Settings.server.upload_server.to_a.sample(1).first.second['address'] + upload_user_videos_path + '.json',
                    :token => one_time_token.token}
    end
  end

  # in upload server
  def upload
    video = user_video_params[:video]
    video_name = user_video_params[:video_name].strip
    publish_strategy = user_video_params[:publish_strategy].to_i
    video_list_id = user_video_params[:video_list_id].to_i
    default_transcoding_strategy = user_video_params[:default_transcoding_strategy]
    if publish_strategy == UserVideo::PUBLISH_STRATEGY::TRANSCODING_AND_PUBLISH
      transcoding_strategy = TranscodingStrategy.find(default_transcoding_strategy)
    end

    if video.blank?
      render :status => 400, :json => {:message => '必须选择视频'}
      return
    end
    ActiveRecord::Base.transaction do
      @user_video = UserVideo.new(:owner => current_user.owner,
                                  :creator => current_user,
                                  :video_name => video_name)
      @user_video.update_video_list! video_list_id
      @user_video.set_video_and_publish(video, publish_strategy, transcoding_strategy)
      unless @user_video.save
        render :status => 400, :json => {:message => '输入视频名称'}
        return
      end
    end

    render :json => {:message => 'succeed'}
  end

  private

  def user_video_params
    params.require(:user_video).permit(:video_name, :video, :video_list_id, :default_transcoding_strategy, :publish_strategy)
  end

  def verify_one_time_token
    arel = OneTimeToken.arel_table
    if OneTimeToken.where(:token => params[:token], :used => false).where(arel[:expire_time].gteq(Time.now)).update_all(:used => true) == 0
      logger.warn 'invalid one time token.'
      raise 'Cannot verify token.'
    end
    @cache_form = OneTimeToken.find_by_token(params[:token]).cache_form
    @current_user = @cache_form.user
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
    headers['Access-Control-Max-Age'] = '1728000'
  end
end
