class TranscodingsController < ApplicationController
  before_action :set_transcoding, only: [:show, :edit, :update, :destroy]

  # GET /transcodings
  # GET /transcodings.json
  def index
    @transcodings = Transcoding.all
  end

  # GET /transcodings/1
  # GET /transcodings/1.json
  def show
  end

  # GET /transcodings/new
  def new
    @transcoding = Transcoding.new
  end

  # GET /transcodings/1/edit
  def edit
  end

  # POST /transcodings
  # POST /transcodings.json
  def create
    @transcoding = Transcoding.new(transcoding_params)

    respond_to do |format|
      if @transcoding.save
        format.html { redirect_to @transcoding, notice: 'Transcoding was successfully created.' }
        format.json { render :show, status: :created, location: @transcoding }
      else
        format.html { render :new }
        format.json { render json: @transcoding.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transcodings/1
  # PATCH/PUT /transcodings/1.json
  def update
    respond_to do |format|
      if @transcoding.update(transcoding_params)
        format.html { redirect_to @transcoding, notice: 'Transcoding was successfully updated.' }
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
    @transcoding.destroy
    respond_to do |format|
      format.html { redirect_to transcodings_url, notice: 'Transcoding was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transcoding
      @transcoding = Transcoding.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcoding_params
      params.require(:transcoding).permit(:name, :user_id, :output_format, :quality, :speed, :audio_encode, :audio_sample_rate, :audio_code_rate, :video_line_scan, :h_w_percent, :width, :height, :data)
    end
end
