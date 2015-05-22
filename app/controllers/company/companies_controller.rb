class Company::CompaniesController < ApplicationController
  def index
    @company_owners = User.company_owners.page(params[:page])
  end

  def show
  end

  def new
    @company_account = Account.new
    @company_account.user = User.new(:role => Settings.role.company_owner)
    @company_account.user.company = Company.new
  end

  def create
    ActiveRecord::Base.transaction do
      @company_account = Account.new(company_account_params.except(:user))
      @company_account.user = User.new(company_account_params[:user].except(:company))
      @company_account.user.role = Settings.role.company_owner
      @company_account.user.company = Company.new(company_account_params[:user][:company])
      @company_account.username = @company_account.user.nickname
      respond_to do |format|
        if @company_account.save
          format.html { redirect_to companies_path, notice: 'Company owner was successfully created.' }
          format.json { render :show, status: :created, location: @company_account }
        else
          format.html { render :new }
          format.json { render json: @company_account.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def company_account_params
    params.require(:company_account).permit(:email, :password, :password_confirmation, :user => [:nickname, :company => :name])
  end
end
