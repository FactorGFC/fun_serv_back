class RemoveColumnsFromCustomer < ActiveRecord::Migration[6.0]
  def change
    remove_column :customers, :debt_rate, :decimal
    remove_column :customers, :cash_flow, :decimal
    remove_column :customers, :credit_status
    remove_column :customers, :previus_credit
    remove_column :customers, :discounts, :decimal
    remove_column :customers, :debt_horizon, :decimal
    remove_column :customers, :report_date
    remove_column :customers, :mop_key
    remove_column :customers, :last_key, :decimal
    remove_column :customers, :balance_due
    remove_column :customers, :payment_capacity, :decimal
    remove_column :customers, :lowest_key, :decimal
    remove_column :customers, :departamental_credit, :decimal
    remove_column :customers, :car_credit, :decimal
    remove_column :customers, :mortagage_loan, :decimal
    remove_column :customers, :other_credits, :decimal
    remove_column :customers, :accured_liabilities, :decimal
    remove_column :customers, :debt, :decimal
    remove_column :customers, :net_flow, :decimal
  end
end
