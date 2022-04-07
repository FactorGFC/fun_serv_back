# frozen_string_literal: true
class AddColumnsToSimCustomerPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :sim_customer_payments, :insurance, :decimal, precision: 15, scale: 4
    add_column :sim_customer_payments, :commission, :decimal, precision: 15, scale: 4
    add_column :sim_customer_payments, :payment_capacity, :decimal, precision: 15, scale: 4
  end
end
