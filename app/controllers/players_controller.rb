class PlayersController < ApplicationController
  before_action :authenticate_account!, except: [:show] # 匿名用户也可以加载播放器设置
  before_action :set_user_id, only: [:create, :update]
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  def index
    @players = Player.visible(current_user).page(params[:page])
  end

  def show
    if @player.logo
      case @player.logo_position
        when 'top_left'
          xpos = 0
          ypos = 0
        when 'bottom_right'
          xpos = 100
          ypos = 100
        when 'bottom_left'
          xpos = 0
          ypos = 100
        when 'top_right'
          xpos = 100
          ypos = 0
      end
      hash_water = {
          # file: @player.logo.uri_url(:normal) ,
          xpos: xpos,
          ypos: ypos,
          xrepeat: 0,
          opacity: 0.5
      }
      hash_water[:file] = @player.logo.uri_url(:normal) if not Rails.env.test?
    end

    respond_to do |format|
      format.html
      format.json {
        json_data = {
            init: {
                controls: true,
                preload: 'meta',
                autoplay: @player.autoplay ? @player.autoplay : false,
                width: @player.width ? @player.width : 852,
                height: @player.height ? @player.height : 480,
            },
            # logo: hash_water
        }
        json_data[:logo] = hash_water if @player.logo
        render json: json_data
      }
    end
  end

  def new
    @player = Player.new
    @player.autoplay = false
    @logos = {}
    logos = Logo.visible(current_user)
    logos.each do |logo|
      @logos[logo.name] = logo.id
    end
  end

  def edit
    @logos = {}
    logos = Logo.visible(current_user)
    logos.each do |logo|
      @logos[logo.name] = logo.id
    end
  end

  def create
    @player = Player.new(player_params)
    @player.creator = current_user

    respond_to do |format|
      if @player.save
        format.html { redirect_to action: "index", notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_player
    if params[:id] == '0'
      @player = Player.new(Settings.default_player.to_h)
    else
      @player = Player.visible(current_user).find(params[:id])
    end
    @player.logo = Logo.find(6)
  end

  def player_params
    params.require(:player).permit(:name, :user_id, :color, :logo_id, :logo_position, :autoplay, :share, :full_screen, :width, :height, :whitelist)
  end
end
