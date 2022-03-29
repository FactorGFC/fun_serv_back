# frozen_string_literal: true

class Api::V1::SimFunderYieldsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::SimFunderYieldsApi

  before_action :authenticate
  before_action :set_sim_funder_yield, only: %i[show update destroy]
  before_action :set_investment

  # GET /investments/:investment_id/sim_funder_yields
  def index
    @sim_funder_yields = @investment.sim_funder_yields
  end

  # GET /investments/:investment_id/sim_funder_yields/2
  def show; end

  # POST /investments/1/sim_funder_yields
  def create
    @sim_funder_yield = @investment.sim_funder_yields.new(sim_funder_yield_params)
    if @sim_funder_yield.save
      render template: 'api/v1/sim_funder_yields/show'
    else
      render json: { error: @sim_funder_yield.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /investments/:investment_id/sim_funder_yields/2
  def update
    if @sim_funder_yield.update(sim_funder_yield_params)
      render template: 'api/v1/sim_funder_yields/show'
    else
      render json: { error: @sim_funder_yield.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /investments/1/sim_funder_yields/1
  def destroy
    @sim_funder_yield.destroy
    render json: { message: 'La simulación de rendimineto del inversionista fue eliminada' }
  end

  private

  def sim_funder_yield_params
    params.require(:sim_funder_yield).permit(:funder_id, :yield_number, :capital, :gross_yield, :isr, :net_yield, :total, :payment_date, :status, :attached, :remaining_capital, :current_capital)
  end

  def set_investment
    @investment = Investment.find(params[:investment_id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró la inversión con el id: #{params[:investment_id]}")
    error_array!(@error_desc, :not_found)
  end

  def set_sim_funder_yield
    @sim_funder_yield = SimFunderYield.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró la simulación de rendimiento del inversionista con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end
end
