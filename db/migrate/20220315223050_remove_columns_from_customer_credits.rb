class RemoveColumnsFromCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_credits, :debt_rate, :decimal
    remove_column :customer_credits, :cash_flow, :decimal
    remove_column :customer_credits, :credit_status
    remove_column :customer_credits, :previus_credit
    remove_column :customer_credits, :discounts, :decimal
    remove_column :customer_credits, :debt_horizon, :decimal
    remove_column :customer_credits, :report_date
    remove_column :customer_credits, :mop_key
    remove_column :customer_credits, :last_key, :decimal
    remove_column :customer_credits, :balance_due
    remove_column :customer_credits, :payment_capacity, :decimal
    remove_column :customer_credits, :lowest_key, :decimal
  end
end
