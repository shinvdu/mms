class LogosController < ApplicationController
  before_action :authenticate_account!
  before_action :set_user_id, only: [:create, :update]
  before_action :set_logo, only: [:show, :edit, :update, :destroy]

  def index
    @logos = Logo.visible(current_user).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @logo = Logo.new
  end

  def edit
  end

  def create
    @logo = Logo.new(logo_params)

    respond_to do |format|
      if @logo.save
        format.html { redirect_to @logo, notice: 'Logo was successfully created.' }
        format.json { render :show, status: :created, location: @logo }
      else
        format.html { render :new }
        format.json { render json: @logo.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @logo.update(logo_params)
        format.html { redirect_to @logo, notice: 'Logo was successfully updated.' }
        format.json { render :show, status: :ok, location: @logo }
      else
        format.html { render :edit }
        format.json { render json: @logo.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @logo.destroy
    respond_to do |format|
      format.html { redirect_to logos_url, notice: 'Logo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_logo
      @logo = Logo.visible(current_user).find(params[:id])
    end

    def logo_params
      params.require(:logo).permit(:name, :user_id, :uri, :width, :height, :filemime, :filesize, :origname)
    end
end
