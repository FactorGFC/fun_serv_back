# frozen_string_literal: true

class Api::V1::FundingRequestsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::FundingRequestsApi

  before_action :authenticate
  before_action :set_funding_request, only: %i[show update destroy]

  def index
    @funding_requests = FundingRequest.all
  end

  def show; end

  def create        
    @funding_request = FundingRequest.new(funding_requests_params)
    if @funding_request.save
      render 'api/v1/funding_requests/show'
    else
      error_array!(@funding_request.errors.full_messages, :unprocessable_entity)
    end    
  end

  def update
    @funding_request.update(funding_requests_params)
    render 'api/v1/funding_requests/show'
  end

  def destroy
    @funding_request.destroy
    render json: { message: 'Fué eliminada la solicitud de fondeo indicada' }
  end

  private

  def set_funding_request
    @funding_request = FundingRequest.find(params[:id])
  end

  def funding_requests_params
    params.require(:funding_request).permit(:total_requested, :total_investments, :balance, :funding_request_date, :funding_due_date, :status, :attached, :project_id)
  end
end
