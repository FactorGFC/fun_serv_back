# frozen_string_literal: true
class RemoveColumnPaymentCapacity < ActiveRecord::Migration[6.0]
  def change
    remove_column :sim_customer_payments, :payment_capacity, :decimal
  end
end
