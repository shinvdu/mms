class UsersController < ApplicationController
  before_action :authenticate_account!
      # 只能操作自己的帐户, 第一个用户为超级用户,  例外
  before_action :restrict_user, only: [:show, :edit, :update,  :destroy]
    # 只有超级用户才有手动创建用户的权限 
  before_action :only_admin, only: [:create, :index]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /user
  # GET /user.json
  def index
    # @users = User.all
  end

  # GET /user/1
  # GET /user/1.json
  def show

  end

  # GET /user/new
  def new
    @user = User.new
  end

  # GET /user/1/edit
  def edit
  end

  # POST /user
  # POST /user.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id]) if @user.nil?
    end

    def restrict_user
      if @current_user.admin?
          return
      end
      # 只能操作自己的帐户
      @user = User.find(params[:id])
      if @current_user.uid != @user.uid
        redirect_to :root 
        return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:uid, :nickname, :role, :sex, :really_name, :birthday, :signature, :avar, :location, :self_introduction, :token,  :scret_key, :mobile, :wechat, :qq, :weibo, :twitter_id, :facebook, :website, :note)
    end
end
