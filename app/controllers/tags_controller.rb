class TagsController < ApplicationController
  before_action :authenticate_account!#, except: [:show]  
  before_action  only: [:create, :update] do 
    set_user_id('tag')
  end
  before_action :set_tag, only: [:show,  :destroy]
  # 只有超级用户可以删除
  before_action :restrict_tag_only_root, only: [:destroy]

  # GET /tags
  # GET /tags.json
  def index
    # @tags = Tag.all
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    def restrict_tag_only_root
      # 第一个用户为超级用户
      if @current_user.uid == 1
        return
      else
        redirect_to :root 
        return
      end
    end   

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name, :user_id, :desc, :note)
    end
end
