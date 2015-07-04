class ReceiptsController < ApplicationController

  before_action :validate_api_token

  respond_to :html, :json

  #
  # GET /receipts.json
  #
  def show
    if @api_token
      @receipts = @api_token.store.receipts
      respond_with @receipts
    else
      # unauthorized
      render json: { status:"error",
                       mesg:"Invalid API token" }, status: 401
    end
  end

  #
  # POST /receipts.json
  #
  def create
    if @api_token
      @receipt = Receipt.create receipt_params
      # Make sure there's a receipt_path in routes.rb
      # The responder will look for a receipt_path even though it's
      # not actually redirecting (as in the case of JSON response)
      respond_with @receipt
      # equivalent to:
      # respond_to do |format|
      #   if @receipt.save
      #     format.json { render json: @receipt, location: receipt_path }
      #   else
      #     format.json { render json: @receipt.errors, status: :unprocessable_entity }
      #   end
      # end
    else
      # unauthorized
      render json: { status:"error",
                       mesg:"Invalid API token" }, status: 401
    end
  end

  private

  def validate_api_token
    @api_token = ApiToken.find_by hex_value:params[:api_token]
  end

  def receipt_params
    # permit all receipt attributes
    # maybe not secure, but not typing everying out
    # TODO: a better way?
    params.require(:receipt).permit!
  end

end
