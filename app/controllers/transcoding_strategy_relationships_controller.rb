class TranscodingStrategyRelationshipsController < ApplicationController
  before_action :set_transcoding_strategy_relationship, only: [:show, :edit, :update, :destroy]

  # GET /transcoding_strategy_relationships
  # GET /transcoding_strategy_relationships.json
  def index
    @transcoding_strategy_relationships = TranscodingStrategyRelationship.all
  end

  # GET /transcoding_strategy_relationships/1
  # GET /transcoding_strategy_relationships/1.json
  def show
  end

  # GET /transcoding_strategy_relationships/new
  def new
    @transcoding_strategy_relationship = TranscodingStrategyRelationship.new
  end

  # GET /transcoding_strategy_relationships/1/edit
  def edit
  end

  # POST /transcoding_strategy_relationships
  # POST /transcoding_strategy_relationships.json
  def create
    @transcoding_strategy_relationship = TranscodingStrategyRelationship.new(transcoding_strategy_relationship_params)

    respond_to do |format|
      if @transcoding_strategy_relationship.save
        format.html { redirect_to @transcoding_strategy_relationship, notice: 'Transcoding strategy relationship was successfully created.' }
        format.json { render :show, status: :created, location: @transcoding_strategy_relationship }
      else
        format.html { render :new }
        format.json { render json: @transcoding_strategy_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transcoding_strategy_relationships/1
  # PATCH/PUT /transcoding_strategy_relationships/1.json
  def update
    respond_to do |format|
      if @transcoding_strategy_relationship.update(transcoding_strategy_relationship_params)
        format.html { redirect_to @transcoding_strategy_relationship, notice: 'Transcoding strategy relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @transcoding_strategy_relationship }
      else
        format.html { render :edit }
        format.json { render json: @transcoding_strategy_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transcoding_strategy_relationships/1
  # DELETE /transcoding_strategy_relationships/1.json
  def destroy
    @transcoding_strategy_relationship.destroy
    respond_to do |format|
      format.html { redirect_to transcoding_strategy_relationships_url, notice: 'Transcoding strategy relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transcoding_strategy_relationship
      @transcoding_strategy_relationship = TranscodingStrategyRelationship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcoding_strategy_relationship_params
      params.require(:transcoding_strategy_relationship).permit(:transcoding_id, :transcoding_strategy_id, :user_id)
    end
end
