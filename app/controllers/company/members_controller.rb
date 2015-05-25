class Company::MembersController < ApplicationController
  before_action :set_company
  before_action :set_company_member, :except => [:new, :create]

  def new
    @member_account = Account.new
    @member_account.user = User.new(:role => Settings.role.company_member)
    @member_account.user.company = @company
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @member_account = Account.new(member_account_params)
        @member_account.user.company = @company
        @member_account.user.role = Settings.role.company_member
        @member_account.username = @member_account.user.nickname
        @member_account.save!
        respond_to do |format|
          format.html { redirect_to company_path(@company), notice: 'Company owner was successfully created.' }
          format.json { render :show, status: :created, location: @member_account }
        end
      end
    rescue
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @member_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def upgrade
    @member.role = Settings.role.company_admin
    @member.save!
    redirect_referrer_or_default
  end

  def downgrade
    @member.role = Settings.role.company_member
    @member.save!
    redirect_referrer_or_default
  end

  def activate
    @member.activate
    redirect_referrer_or_default
  end

  def inactivate
    @member.inactivate(User::FROZEN_REASON::COMPANY_ADMIN % current_user.nickname)
    redirect_referrer_or_default
  end

  private

  def set_company_member
    @member = User.where(:company => @company).find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def member_account_params
    params.require(:member_account).permit(:email, :password, :password_confirmation, :user_attributes => [:nickname])
  end
end
