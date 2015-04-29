class TranscodingStrategiesController < ApplicationController
  before_action :authenticate_account! #, except: [:show]
  before_action only: [:create, :update] do
    set_user_id('transcoding_strategy')
  end
  before_action :set_transcoding_strategy, only: [:show, :edit, :update, :destroy]
  before_action :restrict_transcoding_strategies, only: [:show, :edit, :update, :destroy]

  # GET /transcoding_strategies
  # GET /transcoding_strategies.json
  def index
    @transcoding_strategies = TranscodingStrategy.visiable(current_user)
    @relationship = []
  end

  # GET /transcoding_strategies/1
  # GET /transcoding_strategies/1.json
  def show
  end

  # GET /transcoding_strategies/new
  def new
    @transcoding_strategy = TranscodingStrategy.new
    @existing_transcodings = []
  end

  # GET /transcoding_strategies/1/edit
  def edit
    @existing_transcodings = @transcoding_strategy.transcodings
  end

  # POST /transcoding_strategies
  # POST /transcoding_strategies.json
  def create
    new_transcoding_ids = transcoding_strategy_params[:transcodings]
    params[:transcoding_strategy].delete :transcodings
    @transcoding_strategy = TranscodingStrategy.new(transcoding_strategy_params)
    new_transcoding_ids.each do |transcoding_id|
      TranscodingStrategyRelationship.create(:transcoding_strategy => @transcoding_strategy, :transcoding_id => transcoding_id)
    end

    respond_to do |format|
      if @transcoding_strategy.save
        format.html { redirect_to @transcoding_strategy, notice: 'Transcoding strategy was successfully created.' }
        format.json { render :show, status: :created, location: @transcoding_strategy }
      else
        format.html { render :new }
        format.json { render json: @transcoding_strategy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transcoding_strategies/1
  # PATCH/PUT /transcoding_strategies/1.json
  def update
    @transcoding_strategy.transcoding_strategy_relationships.each do |relation|
      relation.destroy if transcoding_strategy_params[:transcodings].index(relation.transcoding_id).nil?
    end
    existed_transcoding_ids = @transcoding_strategy.transcodings.map { |t| t.id }
    transcoding_strategy_params[:transcodings].each do |transcoding_id|
      if existed_transcoding_ids.index(transcoding_id).nil?
        TranscodingStrategyRelationship.create(:transcoding_strategy => @transcoding_strategy, :transcoding_id => transcoding_id)
      end
    end
    respond_to do |format|
      params[:transcoding_strategy].delete :transcodings
      if @transcoding_strategy.update(transcoding_strategy_params)
        format.html { redirect_to @transcoding_strategy, notice: 'Transcoding strategy was successfully updated.' }
        format.json { render :show, status: :ok, location: @transcoding_strategy }
      else
        format.html { render :edit }
        format.json { render json: @transcoding_strategy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transcoding_strategies/1
  # DELETE /transcoding_strategies/1.json
  def destroy
    @transcoding_strategy.destroy
    respond_to do |format|
      format.html { redirect_to transcoding_strategies_url, notice: 'Transcoding strategy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_transcoding_strategy
    @transcoding_strategy = TranscodingStrategy.find(params[:id])
  end

  def restrict_transcoding_strategies
    # 第一个用户为超级用户
    if @current_user.uid == 1
      return
    end
    # transcoding_strategy
    if @current_user.uid != @transcoding_strategy.user_id
      redirect_to :root
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transcoding_strategy_params
    params.require(:transcoding_strategy).permit(:name, :user_id, :note, :transcodings => [])
  end
end
