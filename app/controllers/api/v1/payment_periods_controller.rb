class Api::V1::PaymentPeriodsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::PaymentPeriodsApi
  
  before_action :authenticate
  before_action :set_payment_period, only: %i[show update destroy]

  def index
    @payment_periods = PaymentPeriod.all
  end

  def show; end

  def create
    @payment_period = PaymentPeriod.new(payment_periods_params)
    if @payment_period.save
      render 'api/v1/payment_periods/show'
    else
      error_array!(@payment_period.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @payment_period.update(payment_periods_params)
    render 'api/v1/payment_periods/show'
  end

  def destroy
    @payment_period.destroy
    render json: { message: 'Fué eliminado el periodo de pago indicado' }
  end

  private

  def set_payment_period
    @payment_period = PaymentPeriod.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el periodo de pago con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def payment_periods_params
    params.require(:payment_period).permit(:key, :description, :value, :pp_type)
  end
end