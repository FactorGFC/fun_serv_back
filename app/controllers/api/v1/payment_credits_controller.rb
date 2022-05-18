# frozen_string_literal: true

class Api::V1::PaymentCreditsController < Api::V1::MasterApiController
  #include Swagger::Blocks
  #include Swagger::PaymentInvoicesApi

  before_action :authenticate
  before_action :set_payment_credit, only: %i[update destroy]
  def create
    payment = Payment.find(params[:payment_id])
    customer_credit = CustomerCredit.find(params[:customer_credit_id])
    @payment_credit = PaymentCredit.custom_update_or_create(payment, customer_credit, params[:pc_type], params[:total])

    if @payment_credit
      render template: 'api/v1/payment_credits/show'
    else
      error_array!(@payment_invoice.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @payment_credit.destroy
    render json: { message: 'Fué eliminada el credito para el pago indicado' }
  end

  private

  def set_payment_credit
    @payment_credit = PaymentCredit.find(params[:id])
  end
end
