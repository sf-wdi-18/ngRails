class StoresController < ApplicationController

  #
  # GET /store/new
  #
  def new
    @store = Store.new
  end

  #
  # GET /store/:id
  #
  def show
  end

  def edit
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
      @errors = @store.errors.messages
      render :new
    end
  end

  #
  # PUT /stores/:id
  #
  def update
  end

  #
  # DELETE /stores/:id
  #
  def destroy
  end

  private

  def store_params
    params.require(:store).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
  end

  def assign_api_token store
    # not worrying about checking hex_value uniqueness validation
    @api_token = ApiToken.create(store_id:store.id, hex_value:SecureRandom.hex)
  end

end
