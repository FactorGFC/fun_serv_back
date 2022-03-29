class ChangePaymentDateFromSimCustomerPayment < ActiveRecord::Migration[6.0]
  def change
    remove_column :sim_customer_payments, :payment_date
    add_column :sim_customer_payments, :payment_date, :date
  end
end
