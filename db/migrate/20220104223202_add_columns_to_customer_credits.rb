# frozen_string_literal: true
class AddColumnsToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
   add_column :customer_credits, :rate, :decimal, null: false
   add_column :customer_credits, :insurance, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :commission, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :payment_capacity, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :debt_rate, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :cash_flow, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :credit_status, :string
   add_column :customer_credits, :debt_time, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :previus_credit, :string
   add_column :customer_credits, :discounts, :decimal, precision: 15, scale: 4
   add_column :customer_credits, :aditional_payment, :decimal, precision: 15, scale: 4
  end
end
