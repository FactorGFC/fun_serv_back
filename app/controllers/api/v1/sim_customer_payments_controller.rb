# frozen_string_literal: true

class Api::V1::SimCustomerPaymentsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::SimCustomerPaymentsApi

  before_action :authenticate
  before_action :set_sim_customer_payment, only: %i[show update destroy]
  before_action :set_customer_credit

  # GET /customer_credits/:customer_credit_id/sim_customer_payments
  def index
    @sim_customer_payments = @customer_credit.sim_customer_payments
  end

  # GET /customer_credits/:customer_credit_id/sim_customer_payments/2
  def show; end

  # POST /customer_credits/1/sim_customer_payments
  def create
    @sim_customer_payment = @customer_credit.sim_customer_payments.new(sim_customer_payment_params)
    if @sim_customer_payment.save
      render template: 'api/v1/sim_customer_payments/show'
    else
      render json: { error: @sim_customer_payment.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /customer_credits/:customer_credit_id/sim_customer_payments/2
  def update
    if @sim_customer_payment.update(sim_customer_payment_params)
      render template: 'api/v1/sim_customer_payments/show'
    else
      render json: { error: @sim_customer_payment.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /customer_credits/1/sim_customer_payments/1
  def destroy
    @sim_customer_payment.destroy
    render json: { message: 'El pago del crédito fue eliminado' }
  end

  private

  def sim_customer_payment_params
    params.require(:sim_customer_payment).permit(:pay_number, :current_debt, :remaining_debt, :payment, :capital, :interests, :iva, :payment_date, :status, :attached)
  end

  def set_customer_credit
    @customer_credit = CustomerCredit.find(params[:customer_credit_id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el crédito con el id: #{params[:customer_credit_id]}")
    error_array!(@error_desc, :not_found)
  end

  def set_sim_customer_payment
    @sim_customer_payment = SimCustomerPayment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontro la simulaición de pago de crédito con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end
end
