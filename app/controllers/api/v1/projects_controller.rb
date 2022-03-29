# frozen_string_literal: true

require 'rest-client'
require 'json'
class Api::V1::ProjectsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ProjectsApi

  before_action :authenticate
  before_action :set_project, only: %i[show update destroy]

  def index
    @projects = Project.all
  end

  def show; end

  def create
    @error_desc = []
    @project = Project.new(projects_params)
    ActiveRecord::Base.transaction do
      
      @project.interests = 0
      @project.client_rate = 0
      @project.funder_rate = 0
      @project.ext_rate = 0
      @project.financial_cost = 0
      if @project.save
        rates = Rate.where(term_id: projects_params[:term_id], payment_period_id: projects_params[:payment_period_id], credit_rating_id: projects_params[:credit_rating_id])
        rate = rates[0]
        if rate.blank?
          @error_desc.push("No existe una tasa con el term_id: #{projects_params[:term_id]} y con el payment_period_id: #{projects_params[:payment_period_id]}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          parameter_year_base = GeneralParameter.get_general_parameter_value('BASE_ANUAL_DIAS')
          funder_dif_rate = GeneralParameter.get_general_parameter_value('FUNDER_DIF_RATE')
          @tiie_date = projects_params[:entry_date]
          calculate_final_rate_pesos
          financial_cost_rate = @final_rate.to_f + rate.value.to_f
          client_rate = rate.value.to_f
          funder_rate = client_rate.to_f - funder_dif_rate.to_f
          create_customer_credit(@project.total, 'AC', @project.entry_date, @project.customer_id, @project.term_id, @project.payment_period_id, financial_cost_rate.to_f, nil, @project.id)          
          term_days = (@customer_credit.end_date - @customer_credit.start_date).to_i
          financial_cost = (financial_cost_rate / parameter_year_base.to_f) * term_days          
          @project.update(interests: @interests.round(2), client_rate: client_rate.to_f, funder_rate: funder_rate.to_f, ext_rate: @final_rate.to_f, financial_cost: financial_cost.to_f)
          render 'api/v1/projects/show'
        end
      else
        error_array!(@project.errors.full_messages, :unprocessable_entity)
      end
    end  
  end

  def update
    ActiveRecord::Base.transaction do
      if @project.update(projects_params)
        status = projects_params[:status]
        if status == 'AP'
          @funding_request = FundingRequest.create(total_requested: @project.total, total_investments: "0.00", balance: @project.total, funding_request_date: DateTime.now, funding_due_date: @project.used_date - 2.days, status: 'AC', project_id: @project.id)
          if @funding_request.save
            render 'api/v1/projects/show'
          else
            render json: @project.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        else
          render 'api/v1/projects/show'
        end        
      else
        render json: @project.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @project.destroy
    render json: { message: 'Fué eliminado el proyecto indicado' }
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def projects_params
    params.require(:project).permit(:project_type, :folio, :client_rate, :funder_rate, :ext_rate, :total, :interests, :financial_cost, :currency, :entry_date, :used_date, :status, :attached, :customer_id, :user_id, :project_request_id, :term_id, :payment_period_id, :credit_rating_id)
  end
end