class Company::OwnersController < ApplicationController
  def index
    @company_owners = User.company_owners.page(params[:page])
  end

  def new
    @company_owner = User.new(:role => Settings.role.company_owner)
    @company_owner.company = Company.new
    @company_owner.account = Account.new
  end

  def create
    @company_owner = User.new(company_owner_params)
    @company_owner.company = Company.new(company_params)
    @company_owner.account = Account.new(account_params)
    respond_to do |format|
      if @company_owner.save
        format.html { redirect_to :index, notice: 'Company owner was successfully created.' }
        format.json { render :show, status: :created, location: @company_owner }
      else
        format.html { render :new }
        format.json { render json: @company_owner.errors, status: :unprocessable_entity }
      end
    end
  end

  private


end
