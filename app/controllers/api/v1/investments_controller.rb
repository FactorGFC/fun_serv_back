# frozen_string_literal: true

class Api::V1::InvestmentsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::InvestmentsApi

  before_action :authenticate
  before_action :set_investment, only: %i[show update destroy]
  before_action :set_funding_request

  # GET /funding_requests/:funding_request_id/investment
  def index
    @investments = @funding_request.investments
  end

  # GET /funding_requests/:funding_request_id/investment/2
  def show; end

  # POST /funding_requests/1/investment
  def create
    @investment = @funding_request.investments.new(investment_params)
    ActiveRecord::Base.transaction do
      @investment.rate = 0
      @investment.yield_fixed_payment = 0
      if @investment.save
        @funding_requests = FundingRequest.where(id: @investment.funding_request_id)
        @funding_request = @funding_requests[0]
        if @funding_request.blank?
          @error_desc.push("No existe una solicitud de fondeo con el id: #{@investment.funding_request_id}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          @projects = Project.where(id: @funding_request.project_id)
          @project = @projects[0]
          if @project.blank?
            @error_desc.push("No existe un proyecto con el id: #{@funding_request.project_id}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          else
            @investment.update(rate: @project.funder_rate)
            @terms = Term.where(id: @project.term_id)
            @term = @terms[0]
            if @term.blank?
              @error_desc.push("No existe un plazo con el id: #{@project.term_id}")
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
            else
              @payment_periods = PaymentPeriod.where(id: @project.payment_period_id)
              @payment_period = @payment_periods[0]
              if @payment_period.blank?
                @error_desc.push("No existe un periodo con el id: #{@project.payment_period_id}")
                error_array!(@error_desc, :not_found)
                raise ActiveRecord::Rollback
              end
            end            
          end
        end
        calculate_yields
        @investment.update(yield_fixed_payment: @yield_fixed_payment)
        render template: 'api/v1/investments/show'
      else
        render json: { error: @investment.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  # PATCH PUT /funding_requests/:funding_request_id/investment/2
  def update
    if @investment.update(investment_params)
      render template: 'api/v1/investments/show'
    else
      render json: { error: @investment.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /funding_requests/1/investment/1
  def destroy
    @investment.destroy
    render json: { message: 'La inversión fue eliminada' }
  end

  private

  def investment_params
    params.require(:investment).permit(:total, :investment_date, :status, :attached, :funder_id)
  end

  def set_funding_request
    @funding_request = FundingRequest.find(params[:funding_request_id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró la solicitud de fondeo con el id: #{params[:funding_request_id]}")
    error_array!(@error_desc, :not_found)
  end

  def set_investment
    @investment = Investment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró la inversión con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def calculate_yields
    @error_desc = []
    investment_id = @investment.id
    funder_id = @investment.funder_id
    term = @term.value
    payment_period = @payment_period.value
    total_investment = @investment.total
    rate = (@investment.rate.to_f  / payment_period.to_f) / 100
    #rate_without_isr = rate.to_f / 1.16
    used_date = @project.used_date
    payment_amount = (rate.to_f * total_investment.to_f) / (1 - ((1 + (rate.to_f)) ** (-term.to_f)))
    @yield_fixed_payment = payment_amount
    remaining_capital = 0
    if payment_period == 365
      number_of_days = term
      term = 1
    end
    1.upto(term) do |i|
      if i == 1
        gross_yield = total_investment.to_f * rate.to_f
        isr = gross_yield.to_f * 0.16
        net_yield = gross_yield.to_f - isr.to_f
        capital = payment_amount.to_f - gross_yield.to_f
        total = capital.to_f + net_yield.to_f
        current_capital = total_investment.to_f
        remaining_capital = total_investment.to_f - capital.to_f
      else
        gross_yield = remaining_capital.to_f  * rate.to_f
        isr = gross_yield.to_f * 0.16
        net_yield = gross_yield.to_f - isr.to_f
        capital = payment_amount.to_f - gross_yield.to_f
        total = capital.to_f + net_yield.to_f
        current_capital = remaining_capital.to_f
        remaining_capital = remaining_capital.to_f - capital.to_f
      end
      
      case payment_period.to_s
      when '365'
        payment_date = used_date + number_of_days.days
      when '12'
        payment_date = used_date + i.months
      when '1'
        payment_date = used_date + i.years
      when '6'
        payment_date = used_date + (i*2).months
      when '4'
        payment_date = used_date + (i*3).months 
      else
        @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Dias(365), Meses(12), Años(1), Bimestres(6), Trimestres(4)")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
      sim_funder_yield = SimFunderYield.create(investment_id: investment_id, funder_id: funder_id, yield_number: i, current_capital: current_capital, remaining_capital:  remaining_capital, gross_yield: gross_yield,
                            isr: isr, net_yield: net_yield, capital: capital, total: total, payment_date: payment_date, status: 'PE')
      if sim_funder_yield.blank?
        @error_desc.push('Ocurrio un error al crear la simulación de rendimientos')
        error_array!(@error_desc, unprocessable_entity)
        raise ActiveRecord::Rollback
      end
    end
  end
end
