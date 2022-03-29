# frozen_string_literal: true

class Api::V1::ExtRatesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ExtRatesApi

  before_action :authenticate
  before_action :set_ext_rate, only: %i[show update destroy]

  def index
    @ext_rates = ExtRate.all
  end

  def show; end

  def create
    @ext_rate = ExtRate.new(ext_rates_params)
    if @ext_rate.save
      render 'api/v1/ext_rates/show'
    else
      error_array!(@ext_rate.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @ext_rate.update(ext_rates_params)
    render 'api/v1/ext_rates/show'
  end

  def destroy
    @ext_rate.destroy
    render json: { message: 'Fué eliminada la tarifa externa indicada' }
  end

  private

  def set_ext_rate
    @ext_rate = ExtRate.find(params[:id])
  end

  def ext_rates_params
    params.require(:ext_rate).permit(:key, :description, :start_date, :end_date, :value, :rate_type)
  end
end
