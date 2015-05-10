class Advertise::ResourcesController < ApplicationController
  before_action :authenticate_account!#, except: [:show]  
  before_action  only: [:create, :update] do 
    set_user_id('advertise_resource')
  end

  before_action :set_advertise_resource, only: [:show, :edit, :update, :destroy]
  before_action :restrict_advertise_resource, only: [:index, :show, :edit, :update,  :destroy]

  # GET /advertise/resources
  # GET /advertise/resources.json
  def index
    @advertise_resources = Advertise::Resource.where(user_id: current_user.uid).page(params[:page])
  end

  # GET /advertise/resources/1
  # GET /advertise/resources/1.json
  def show
  end

  # GET /advertise/resources/new
  def new
    @advertise_resource = Advertise::Resource.new
  end

  # GET /advertise/resources/1/edit
  def edit
  end

  # POST /advertise/resources
  # POST /advertise/resources.json
  def create
    if user_video_params[:video].blank?
      session[:return_to] ||= request.referer
      notice_warning '请选择资源文件'
      redirect_to session.delete(:return_to)
      return
    end
    @advertise_resource = Advertise::Resource.new({
                                :name => advertise_resource_params[:name],
                                :file_type => advertise_resource_params[:file_type],
                                :ad_type => advertise_resource_params[:ad_type],
                                      }).set_ad_video(advertise_resource_params[:resource])
    respond_to do |format|
      if @advertise_resource.save!
        format.html { redirect_to @advertise_resource, notice: 'Resource was successfully created.' }
        format.json { render :show, status: :created, location: @advertise_resource }
      else
        format.html { render :new }
        format.json { render json: @advertise_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /advertise/resources/1
  # PATCH/PUT /advertise/resources/1.json
  def update
    respond_to do |format|
      if @advertise_resource.update(advertise_resource_params)
        format.html { redirect_to @advertise_resource, notice: 'Resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @advertise_resource }
      else
        format.html { render :edit }
        format.json { render json: @advertise_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /advertise/resources/1
  # DELETE /advertise/resources/1.json
  def destroy
    @advertise_resource.destroy
    respond_to do |format|
      format.html { redirect_to advertise_resources_url, notice: 'Resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_advertise_resource
      @advertise_resource = Advertise::Resource.find(params[:id])
    end    

    def restrict_advertise_resource
      if @current_user.admin?
        return
      end
      # 只能操作自己的player
      if @current_user.uid != @advertise_resource.user_id
        redirect_to :root 
        return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def advertise_resource_params
      params.require(:advertise_resource).permit(:name, :file_type, :ad_type, :filesize, :uri, :resource, :ad_word, :data)
    end
end
