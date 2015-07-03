class ReceiptsController < ApplicationController

  before_action :validate_api_token, only: [:show, :create]
  respond_to :html, :JSON

  #
  # GET /receipts
  #
  def show
    if @api_token
      @receipts = @api_token.store.receipts
      respond_with @receipts
    else
      # no token exists
      render :show
    end
  end

  #
  # POST /receipts
  #
  def create
    if @api_token
      @receipt = Receipt.create receipt_params
      respond_with @receipt
    else
    end
  end

  private

  def validate_api_token
    @api_token = ApiToken.find_by hex_value:params[:api_token]
  end

  def receipt_params
    # permit all receipt attributes
    params.require(:receipt).permit!
  end

end
