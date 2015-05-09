class TranscodingsController < ApplicationController
  before_action :authenticate_account! #, except: [:show]
  before_action only: [:create, :update] do
    set_user_id('transcoding')
  end
  before_action :set_transcoding, only: [:show, :edit, :update, :destroy]
  before_action :restrict_transcoding, only: [:show, :edit, :update, :destroy]

  # GET /transcodings
  # GET /transcodings.json
  def index
    @transcodings = Transcoding.visiable(current_user).page(params[:page])
  end

  # GET /transcodings/1
  # GET /transcodings/1.json
  def show
  end

  # GET /transcodings/new
  def new
    @transcoding = Transcoding.new
    @transcoding.container = 'mp4'
    @transcoding.video_codec = 'H.264'
    @transcoding.video_profile = 'high'
    @transcoding.video_bitrate = 10000
    @transcoding.video_crf = 26

    # @transcoding.video_fps = 30
    @transcoding.video_gop = 250
    @transcoding.video_preset = 'slow'
    @transcoding.video_scanmode = 'progressive'
    @transcoding.video_bufsize = 6000
    @transcoding.video_maxrate = 10000
    @transcoding.video_bitrate_bnd_max = 10000
    @transcoding.video_bitrate_bnd_min = 1000
    @transcoding.audio_codec = 'aac'
    @transcoding.audio_samplerate = 44100
    @transcoding.audio_bitrate = 128
    @transcoding.audio_channels = 2

  end

  # GET /transcodings/1/edit
  def edit
  end

  # POST /transcodings
  # POST /transcodings.json
  def create
    @transcoding = Transcoding.new(transcoding_params).do_save

    respond_to do |format|
      if @transcoding
        format.html { redirect_to @transcoding, notice: 'Transcoding was successfully created.' }
        format.json { render :show, status: :created, location: @transcoding }
      else
        notice_error 'Create transcoding failed.'
        format.html { render :new }
        format.json { render json: @transcoding.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transcodings/1
  # PATCH/PUT /transcodings/1.json
  def update
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

  # DELETE /transcodings/1
  # DELETE /transcodings/1.json
  def destroy
    belong_strategy = TranscodingStrategyRelationship.joins(:transcoding_strategy, :user)
                          .where(['transcoding_id = ? and users.uid = ?', @transcoding, current_user]).present?
    belong_video = VideoDetail.where(:transcoding => @transcoding).present?
    if !belong_strategy
      if belong_video || belong_video
        @transcoding.disable!
      else
        @transcoding.destroy!
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
  # Use callbacks to share common setup or constraints between actions.
  def set_transcoding
    @transcoding = Transcoding.find(params[:id])
  end

  def restrict_transcoding
    if @current_user.admin?
      return
    end
    # 只能操作自己的player
    if @current_user.uid != @transcoding.user_id
      redirect_to :root
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transcoding_params
    params[:transcoding][:user_id] = current_user.uid
    params.require(:transcoding).permit(:name, :user_id, :container, :video_profile, :video_preset, :audio_codec, :audio_samplerate, :audio_bitrate, :width, :height, :video_codec, :video_bitrate, :video_crf, :video_fps, :video_gop, :video_scanmode, :video_bufsize, :video_bitratebnd, :audio_channels, :state, :aliyun_template_id, :created_at, :updated_at, :video_maxrate, :video_bitrate_bnd_max, :video_bitrate_bnd_min)
  end

end
