class AddColumnsToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :debt_rate, :decimal, null: true, precision: 15, scale: 4
    add_column :customers, :cash_flow, :decimal, null: true, precision: 15, scale: 4
    add_column :customers, :credit_status, :string, null: true
    add_column :customers, :previus_credit, :string, null: true
    add_column :customers, :discounts, :decimal, null: true, precision: 15, scale: 4
    add_column :customers, :debt_horizon, :decimal, null: true, precision: 15, scale: 4
    add_column :customers, :report_date, :date, null: true
    add_column :customers, :mop_key, :string, null: true
    add_column :customers, :last_key, :decimal, null: true, precision: 15, scale: 4
    add_column :customers, :balance_due, :string, null: true
    add_column :customers, :payment_capacity, :decimal, null: true, precision: 15, scale: 4
    add_column :customers, :lowest_key, :decimal, null: true, precision: 15, scale: 4
end
end