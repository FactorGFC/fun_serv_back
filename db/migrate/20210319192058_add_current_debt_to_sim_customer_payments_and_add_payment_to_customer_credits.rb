class AddCurrentDebtToSimCustomerPaymentsAndAddPaymentToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    add_column :sim_customer_payments, :current_debt, :decimal, precision: 15, scale: 4, null: false
    add_column :customer_credits, :fixed_payment, :decimal, precision: 15, scale: 4, null: false
  end
end
