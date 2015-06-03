class TranscodingsController < ApplicationController
  before_action :authenticate_account! #, except: [:show]
  before_action only: [:create, :update] do
    set_user_id('transcoding')
  end
  before_action :set_transcoding, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :access, Transcoding
    @transcodings = Transcoding.visible(current_user).page(params[:page])
  end

  def show
  end

  def new
    @transcoding = Transcoding.new(:container => 'mp4',
                                   :video_codec => 'H.264',
                                   :video_profile => 'high',
                                   :video_bitrate => 10000,
                                   :video_crf => 26,
                                   :video_fps => 25,
                                   :video_gop => 250,
                                   :video_preset => 'slow',
                                   :video_scanmode => 'progressive',
                                   :video_bufsize => 6000,
                                   :video_maxrate => 10000,
                                   :video_bitrate_bnd_max => 10000,
                                   :video_bitrate_bnd_min => 1000,
                                   :audio_codec => 'aac',
                                   :audio_samplerate => 44100,
                                   :audio_bitrate => 128,
                                   :audio_channels => 2
    )
  end

  def edit
  end

  def create
    authorize! :create, Transcoding
    @transcoding = Transcoding.new(transcoding_params)
    @transcoding.creator = current_user

    respond_to do |format|
      if @transcoding.do_save
        format.html { redirect_to @transcoding, notice: 'Transcoding was successfully created.' }
        format.json { render :show, status: :created, location: @transcoding }
      else
        notice_error 'Create transcoding failed.'
        format.html { render :new }
        format.json { render json: @transcoding.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, Transcoding
    belong_video = VideoDetail.where(:transcoding => @transcoding).present?
    if belong_video
      new_transcoding = @transcoding.update_by_create!(transcoding_params)
    else
      new_transcoding = @transcoding.update_directly(transcoding_params)
    end
    respond_to do |format|
      if new_transcoding.present?
        format.html { redirect_to new_transcoding, notice: 'Transcoding was successfully updated.' }
        format.json { render :show, status: :ok, location: @transcoding }
      else
        format.html { render :edit }
        format.json { render json: @transcoding.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, Transcoding
    belong_strategy = current_user.owner.transcoding_strategies.joins(:transcoding_strategy_relationships)
                          .where(:transcoding_strategy_relationships => {:transcoding_id => @transcoding}).present?
    belong_video = VideoDetail.where(:transcoding => @transcoding).present?
    if !belong_strategy
      if belong_video || belong_video
        @transcoding.disable!
      else
        @transcoding.disable_and_destroy!
      end
      respond_to do |format|
        format.html { redirect_to transcodings_url, notice: 'Transcoding was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to transcodings_url, alert: 'Transcoding cannot be destroyed, it is included by some transcoding strategy.' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_transcoding
    @transcoding = Transcoding.find(params[:id])
  end

  def transcoding_params
    params[:transcoding][:user_id] = current_user.owner.uid
    params.require(:transcoding).permit(:name, :user_id, :container, :video_profile, :video_preset, :audio_codec, :audio_samplerate, :audio_bitrate, :width, :height, :video_codec, :video_bitrate, :video_crf, :video_fps, :video_gop, :video_scanmode, :video_bufsize, :video_bitratebnd, :audio_channels, :state, :aliyun_template_id, :created_at, :updated_at, :video_maxrate, :video_bitrate_bnd_max, :video_bitrate_bnd_min)
  end

end
