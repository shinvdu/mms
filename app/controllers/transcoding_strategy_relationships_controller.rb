class TranscodingStrategyRelationshipsController < ApplicationController
  before_action :authenticate_account!#, except: [:show]  
  before_action :set_transcoding_strategy_relationship, only: [:show, :edit, :update, :destroy]
  before_action :restrict_transcoding_strategy_operation, only: [:show, :destroy]

  # GET /transcoding_strategy_relationships
  # GET /transcoding_strategy_relationships.json
  # def index
  #   @transcoding_strategy_relationships = TranscodingStrategyRelationship.all
  # end

  # GET /transcoding_strategy_relationships/1
  # GET /transcoding_strategy_relationships/1.json
  def show
  end

  # GET /transcoding_strategy_relationships/new
  def new
    @transcoding_strategy_relationship = TranscodingStrategyRelationship.new
  end

  # POST /transcoding_strategy_relationships
  # POST /transcoding_strategy_relationships.json
  def create
    @transcoding_strategy_relationship = TranscodingStrategyRelationship.new(transcoding_strategy_relationship_params)

    @transcoding = Transcoding.find @transcoding_strategy_relationship.transcoding_id
    @transcoding_strategy = TranscodingStrategy.find @transcoding_strategy_relationship.transcoding_strategy_id
      # 第一个用户为超级用户
    if @current_user.uid == 1
      # 只允许增加自己的视频和检签关系
    elsif not (@transcoding && @transcoding_strategy &&  (@transcoding.user_id == @current_user.uid) && (@transcoding_strategy.user_id == @current_user.uid))
      redirect_to :root 
      return
    end

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

# restrict_transcoding_strategy_operation
    def restrict_transcoding_strategy_operation
      # 第一个用户为超级用户
      if @current_user.uid == 1
        return
      end
      # 只能操作自己的transcoding_strategy_relationship
      if @current_user.uid != @transcoding_strategy_relationship.user_id
        redirect_to :root 
        return
      end
    end   

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcoding_strategy_relationship_params
      params.require(:transcoding_strategy_relationship).permit(:transcoding_id, :transcoding_strategy_id, :user_id)
    end
end
