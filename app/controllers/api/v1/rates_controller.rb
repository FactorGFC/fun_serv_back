# frozen_string_literal: true

class Api::V1::RatesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::RatesApi

  before_action :authenticate
  before_action :set_rate, only: %i[show update destroy]

  def index
    @rates = Rate.all
  end

  def show; end

  def create
    @rate = Rate.new(rates_params)
    if @rate.save
      render 'api/v1/rates/show'
    else
      error_array!(@rate.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @rate.update(rates_params)
    render 'api/v1/rates/show'
  end

  def destroy
    @rate.destroy
    render json: { message: 'Fué eliminada la tasa indicada' }
  end

  private

  def set_rate
    @rate = Rate.find(params[:id])
  end

  def rates_params
    params.require(:rate).permit(:key, :description, :value, :term_id, :payment_period_id, :credit_rating_id, :extra1, :extra2, :extra3)
  end
end
