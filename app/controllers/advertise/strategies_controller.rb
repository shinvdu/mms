class Advertise::StrategiesController < ApplicationController
  before_action :authenticate_account!#, except: [:show]  
  before_action  only: [:create, :update] do 
    set_user_id('advertise_strategy')
  end
  before_action :set_advertise_strategy, only: [:show, :edit, :update, :destroy]
  before_action :restrict_advertise_strategy, only: [:index, :show, :edit, :update,  :destroy]

  # GET /advertise/strategies
  # GET /advertise/strategies.json
  def index
    @advertise_strategies = Advertise::Strategy.where(user_id: current_user.uid)
  end

  # GET /advertise/strategies/1
  # GET /advertise/strategies/1.json
  def show
  end

  # GET /advertise/strategies/new
  def new
    @advertise_strategy = Advertise::Strategy.new
  end

  # GET /advertise/strategies/1/edit
  def edit
  end

  # POST /advertise/strategies
  # POST /advertise/strategies.json
  def create
    @advertise_strategy = Advertise::Strategy.new(advertise_strategy_params)

    respond_to do |format|
      if @advertise_strategy.save
        format.html { redirect_to @advertise_strategy, notice: 'Strategy was successfully created.' }
        format.json { render :show, status: :created, location: @advertise_strategy }
      else
        format.html { render :new }
        format.json { render json: @advertise_strategy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /advertise/strategies/1
  # PATCH/PUT /advertise/strategies/1.json
  def update
    respond_to do |format|
      if @advertise_strategy.update(advertise_strategy_params)
        format.html { redirect_to @advertise_strategy, notice: 'Strategy was successfully updated.' }
        format.json { render :show, status: :ok, location: @advertise_strategy }
      else
        format.html { render :edit }
        format.json { render json: @advertise_strategy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /advertise/strategies/1
  # DELETE /advertise/strategies/1.json
  def destroy
    @advertise_strategy.destroy
    respond_to do |format|
      format.html { redirect_to advertise_strategies_url, notice: 'Strategy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_advertise_strategy
      @advertise_strategy = Advertise::Strategy.find(params[:id])
    end
    
    def restrict_advertise_strategy
      # 第一个用户为超级用户
      if @current_user.uid == 1
        return
      end
      # 只能操作自己的player
      if @current_user.uid != @advertise_strategy.user_id
        redirect_to :root 
        return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def advertise_strategy_params
      params.require(:advertise_strategy).permit(:name, :user_id, :front_ad, :end_ad, :pause_ad, :float_ad, :scroll_ad, :data)
    end
end
