# frozen_string_literal: true

class Api::V1::CustomerPersonalReferencesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CustomerPersonalReferencesApi

  before_action :authenticate
  before_action :set_customer_personal_reference, only: %i[show update destroy]
  # before_action :set_customer

  # GET /customers/:customer_id/customer_personal_references
  def index
    @customer_personal_references = CustomerPersonalReference.all
  end

  # GET /customers/:customer_id/customer_personal_references/2
  def show; end

  # POST /customer/1/customer_personal_references
  def create
    @customer_personal_reference = CustomerPersonalReference.new(customer_personal_reference_params)
    if @customer_personal_reference.save
      render template: 'api/v1/customer_personal_references/show'
    else
      render json: { error: @customer_personal_reference.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT GET /customers/:customer_id/customer_personal_references/2
  def update
    if @customer_personal_reference.update(customer_personal_reference_params)
      render template: 'api/v1/customer_personal_references/show'
    else
      render json: { error: @customer_personal_reference.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /contributors/1/contributor_addresses/1
  def destroy
    @customer_personal_reference.destroy
    render json: { message: '' }
  end

  private

  def customer_personal_reference_params
    params.require(:customer_personal_reference).permit(:first_name, :last_name, :second_last_name, :address, :phone, :reference_type, :customer_id)
  end

  # def set_customer
  # @customer = Customer.find(params[:customer_id])
  #  end

  def set_customer_personal_reference
    @customer_personal_reference = CustomerPersonalReference.find(params[:id])
  end
end
