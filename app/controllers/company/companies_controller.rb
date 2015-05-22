class Company::CompaniesController < ApplicationController
  before_action :set_company, :only => [:show]
  def index
    @company_owners = User.company_owners.page(params[:page])
  end

  def show
    @company_admins = User.company_admins.where(:company => @company).page(params[:admin_page])
    @company_members = User.company_members.where(:company => @company).page(params[:member_page])
  end

  def new
    @company_account = Account.new
    @company_account.user = User.new(:role => Settings.role.company_owner)
    @company_account.user.company = Company.new
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @company_account = Account.new(company_account_params.except(:user))
        @company_account.user = User.new(company_account_params[:user].except(:company))
        @company_account.user.role = Settings.role.company_owner
        @company_account.user.company = Company.new(company_account_params[:user][:company])
        @company_account.username = @company_account.user.nickname
        @company_account.save!
        respond_to do |format|
            format.html { redirect_to companies_path, notice: 'Company owner was successfully created.' }
            format.json { render :show, status: :created, location: @company_account }
        end
      end
    rescue
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @company_account.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_account_params
    params.require(:company_account).permit(:email, :password, :password_confirmation, :user => [:nickname, :company => :name])
  end
end
