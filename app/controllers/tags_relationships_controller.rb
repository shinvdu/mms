class TagsRelationshipsController < ApplicationController
  before_action :authenticate_account!#, except: [:show]  
  before_action  only: [:create, :update] do 
    set_user_id('tags_relationship')
  end
  before_action :set_tags_relationship, only: [:show, :edit, :update, :destroy]
  before_action :restrict_tag_operation, only: [:show, :destroy]

  # GET /tags_relationships
  # GET /tags_relationships.json
  # def index
  #   # @tags_relationships = TagsRelationship.all
  # end

  # GET /tags_relationships/1
  # GET /tags_relationships/1.json
  def show
  end

  # GET /tags_relationships/new
  def new
    @tags_relationship = TagsRelationship.new
    logger.info 'jsot ote st'
  end

  # POST /tags_relationships
  # POST /tags_relationships.json
  def create
    @tags_relationship = TagsRelationship.new(tags_relationship_params)
    ##
    @tag = Tag.find @tags_relationship.tag_id
    @user_video = UserVideo.find @tags_relationship.user_video_id

      # 第一个用户为超级用户
    if @current_user.admin?
      # 只允许增加自己的视频和检签关系
    elsif not (@tag && @user_video &&   (@user_video.owner_id == @current_user.uid))
      redirect_to :root 
      return
    end

    respond_to do |format|
      if @tags_relationship.save
        format.html { redirect_to @tags_relationship, notice: 'Tags relationship was successfully created.' }
        format.json { render :show, status: :created, location: @tags_relationship }
      else
        format.html { render :new }
        format.json { render json: @tags_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # # PATCH/PUT /tags_relationships/1
  # # PATCH/PUT /tags_relationships/1.json
  # def update
  #   respond_to do |format|
  #     if @tags_relationship.update(tags_relationship_params)
  #       format.html { redirect_to @tags_relationship, notice: 'Tags relationship was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @tags_relationship }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @tags_relationship.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /tags_relationships/1
  # DELETE /tags_relationships/1.json
  def destroy
    @tags_relationship.destroy
    respond_to do |format|
      format.html { redirect_to tags_relationships_url, notice: 'Tags relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tags_relationship
      @tags_relationship = TagsRelationship.find(params[:id])
    end
# restrict_tag_operation
    def restrict_tag_operation
      if @current_user.admin?
        return
      end
      # 只能操作自己的player
      if @current_user.uid != @tags_relationship.user_id
        redirect_to :root 
        return
      end
    end   

    # Never trust parameters from the scary internet, only allow the white list through.
    def tags_relationship_params
      params.require(:tags_relationship).permit(:tag_id, :user_video_id, :user_id)
    end
end
