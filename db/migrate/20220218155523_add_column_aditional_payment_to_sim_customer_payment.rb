# frozen_string_literal: true
class AddColumnAditionalPaymentToSimCustomerPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :sim_customer_payments, :aditional_payment, :decimal, precision: 15, scale: 4
  end
end
