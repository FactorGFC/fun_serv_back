# frozen_string_literal: true
class AddColumnPaymentCapacityToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits, :payment_capacity, :decimal, precision: 15, scale: 4
  end
end
