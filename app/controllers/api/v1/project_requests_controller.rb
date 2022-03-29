# frozen_string_literal: true

class Api::V1::ProjectRequestsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ProjectRequestsApi

  before_action :authenticate
  before_action :set_project_request, only: %i[show update destroy]

  def index
    @project_requests = ProjectRequest.all
  end

  def show; end

  def create
    @error_desc = []
    @project_request = ProjectRequest.new(project_requests_params)
    ActiveRecord::Base.transaction do
      if @project_request.save
        rates = Rate.where(term_id: project_requests_params[:term_id], payment_period_id: project_requests_params[:payment_period_id])      
        rate = rates[0]
        if rate.blank?
          @error_desc.push("No existe una tasa con el term_id: #{project_requests_params[:term_id]} y con el payment_period_id: #{project_requests_params[:payment_period_id]}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          @tiie_date = project_requests_params[:request_date]
          calculate_final_rate_pesos
          client_rate = rate.value.to_f
          financial_cost_rate = @final_rate.to_f + client_rate.to_f
          create_customer_credit(@project_request.total, 'AC', @project_request.request_date, @project_request.customer_id, @project_request.term_id, @project_request.payment_period_id, financial_cost_rate, @project_request.id, nil)
          render 'api/v1/project_requests/show'
        end
      else
        error_array!(@project_request.errors.full_messages, :unprocessable_entity)
      end
    end
  end

  def update
    @project_request.update(project_requests_params)
    render 'api/v1/project_requests/show'
  end

  def destroy
    @project_request.destroy
    render json: { message: 'Fué eliminada la solicitud de proyecto indicada' }
  end

  private

  def set_project_request
    @project_request = ProjectRequest.find(params[:id])
  end

  def project_requests_params
    params.require(:project_request).permit(:project_type, :currency, :total, :request_date, :status, :attached, :customer_id, :user_id, :term_id, :payment_period_id)
  end
end
