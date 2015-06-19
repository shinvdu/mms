class TranscodingStrategiesController < ApplicationController
  before_action :authenticate_account!
  before_action only: [:create, :update] do
    set_user_id('transcoding_strategy')
  end
  before_action :set_transcoding_strategy, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :access, TranscodingStrategy
    @transcoding_strategies = TranscodingStrategy.visible(current_user).page(params[:page])
  end

  def show
  end

  def new
    @transcoding_strategy = TranscodingStrategy.new
    @existing_transcodings = []
  end

  def edit
    @existing_transcodings = @transcoding_strategy.transcodings
  end

  def create
    authorize! :create, TranscodingStrategy
    new_transcoding_ids = transcoding_strategy_params[:transcodings]
    params[:transcoding_strategy].delete :transcodings

    ActiveRecord::Base.transaction do
      @transcoding_strategy = TranscodingStrategy.new(transcoding_strategy_params)
      @transcoding_strategy.add_transcodings(new_transcoding_ids)

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
  end

  def update
    authorize! :update, TranscodingStrategy
    transcoding_ids = (transcoding_strategy_params[:transcodings] || []).map { |id| id.to_i }
    @transcoding_strategy.update_transcodings(transcoding_ids, current_user)

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

  def destroy
    authorize! :destroy, TranscodingStrategy
    @transcoding_strategy.destroy
    respond_to do |format|
      format.html { redirect_to transcoding_strategies_url, notice: 'Transcoding strategy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_transcoding_strategy
    @transcoding_strategy = TranscodingStrategy.find(params[:id])
  end

  def transcoding_strategy_params
    params[:transcoding_strategy][:user_id] = current_user.owner.uid
    params.require(:transcoding_strategy).permit(:name, :user_id, :note, :transcodings => [])
  end
end
