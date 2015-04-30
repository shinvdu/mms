class PlayersController < ApplicationController
  before_action :authenticate_account!, except: [:show] # 匿名用户也可以加载播放器设置
  before_action  only: [:create, :update] do 
    set_user_id('player')
  end
  before_action :set_player, only: [:show, :edit, :update, :destroy]
  before_action :restrict_player, only: [:edit, :update,  :destroy]
  before_action :only_root, only: [:index]

  # GET /players
  # GET /players.json
  def index
    @players = Player.where(user_id: current_user.uid).page(params[:page])
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
    @logos = {}
    logos = Logo.where(user_id: current_user.uid)
    logos.each do |logo |
      @logos[logo.name] = logo.id
    end
  end

  # GET /players/1/edit
  def edit
    @logos = {}
    logos = Logo.where(user_id: current_user.uid)
    logos.each do |logo |
      @logos[logo.name] = logo.id
    end
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def restrict_player
      # 第一个用户为超级用户
      if @current_user.uid == 1
        return
      end
      # 只能操作自己的player
      if @current_user.uid != @player.user_id
        redirect_to :root 
        return
      end
    end

    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:name, :user_id, :color, :logo_id, :logo_position, :autoplay, :share, :full_screen, :width, :height, :data)
    end
end
