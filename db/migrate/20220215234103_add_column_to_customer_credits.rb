# frozen_string_literal: true
class AddColumnToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits, :destination, :string
    add_column :customer_credits, :debt_horizon, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :amount_allowed, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :time_allowed, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :report_date, :date
    add_column :customer_credits, :mop_key, :string
    add_column :customer_credits, :last_key, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :lowest_key, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :balance_due, :string
  end
end
