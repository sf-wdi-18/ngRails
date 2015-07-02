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
      login(@store)
      redirect_to account_path(@store)
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

end
