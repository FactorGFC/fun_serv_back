# frozen_string_literal: true

class Api::V1::ContributorAddressesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ContributorAddressesApi

  before_action :authenticate
  before_action :set_contributor_address, only: %i[show update destroy]
  before_action :set_contributor

  # GET /contributors/:contributor_id/addresses
  def index
    @contributor_addresses = @contributor.contributor_addresses
  end

  # GET /contributores/:contributor_id/contributor_addresses/2
  def show; end

  # POST /contributors/1/contributor_addresses
  def create
    @contributor_address = @contributor.contributor_addresses.new(contributor_address_params)
    if @contributor_address.save
      render template: 'api/v1/contributor_addresses/show'
    else
      render json: { error: @contributor_address.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /contributores/:contributor_id/contributor_addresses/2
  def update
    if @contributor_address.update(contributor_address_params)
      render template: 'api/v1/contributor_addresses/show'
    else
      render json: { error: @contributor_address.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /contributors/1/contributor_addresses/1
  def destroy
    @contributor_address.destroy
    render json: { message: 'El domicilio del contribuyente fue eliminado' }
  end

  private

  def contributor_address_params
    params.require(:contributor_address).permit(:address_type, :street, :external_number, :apartment_number, :suburb_type, :suburb, :address_reference, :postal_code, :municipality_id, :state_id)
  end

  def set_contributor
    @contributor = Contributor.find(params[:contributor_id])
  end

  def set_contributor_address
    @contributor_address = ContributorAddress.find(params[:id])
  end
end
