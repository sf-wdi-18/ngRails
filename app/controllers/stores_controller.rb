class StoresController < ApplicationController

  before_action :require_login, only: [:show]

  #
  # GET /signup
  #
  def new
    @store = Store.new
  end

  #
  # GET /account/:id
  #
  def show
    @store = Store.find params[:id]
  end

  #
  # POST /stores
  #
  def create
    @store = Store.new store_params
    if @store.save
      assign_api_token @store
      login @store
      redirect_to account_path @store
    else
      render :new
    end
  end

  def passwd_reset
    # can only get here through login form
    # can't go here if logged in
  end

  private

  def store_params
    params.require(:store).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
  end

  def assign_api_token store
    # TODO: handle uniqueness validation failure
    @api_token = ApiToken.create(store_id:store.id, hex_value:SecureRandom.hex)
  end

end
