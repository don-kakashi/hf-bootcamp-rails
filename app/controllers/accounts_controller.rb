class AccountsController < ApplicationController
  after_action :verify_authorized, only: :invite
  before_action :authenticate_account, :only => [:invite]
  before_action :set_account, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # GET /accounts/1
  def show
    render json: @account
  end

=begin
       @api {post} accounts/signin signin a user
       @apiName SigninAccount
       @apiGroup Account

       @apiParam {Object} auth Authentication information (email, password)

       @apiParamExample {json} Request-Example:
       {
        "auth": {
          "email": "email@example.com",
          "password": "NotASekeret"
        }
       }

       @apiSuccess (200)  {String} success message

       @apiError (422) {Object} User Save Error
=end

=begin
       @api {post} /accounts/signup Creates a company account
       @apiName SignAccount
       @apiGroup Account

       @apiParam {String} email Email of the user
       @apiParam {String} password Password of the user
       @apiParam {String} password_confirmation Password confirmation
       @apiParam {String} full_name Full name of the user

       @apiSuccess (200) {String} meta.jwt the Json Web Token of the user
       @apiSuccess (200) {Object} Data Account saved data

       @apiError (422) {Object} Errors Account Save Error
=end

  def signup
    @account = Account.new(account_params)
    @account.add_role "admin"

    jwt_token = Knock::AuthToken.new(payload: { sub: @account.id }).token

    if @account.save
      render json: @account, meta: { jwt: jwt_token }, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
  end

=begin
       @api {post} /accounts/invite invites a user
       @apiName InviteAccount
       @apiGroup Account

       @apiHeader {String} Authorization='Bearer :jwt_token:'

       @apiParam {String} email Email of the user

       @apiSuccess (200)  {Object} data msg invitation sent

       @apiError (422) {Object} errors Account Save Error
       @apiError (401) {Object} msg only admins can send invitations
=end

  def invite
    @account = Account.new(invite_params)
    @account.invited = true
    authorize @account
    if @account.save
      # NOTE: it would be better to have custom messages placed in a special folder
      render json: { data: { msg: "invitation sent" }}, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  def invite_params
    params.require(:account).permit(:email)
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation, :is_admin, :full_name)
  end
end
