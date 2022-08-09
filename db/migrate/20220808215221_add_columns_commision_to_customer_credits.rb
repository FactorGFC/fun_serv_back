class AddColumnsCommisionToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits, :insurance, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :commission, :decimal, precision: 15, scale: 4
  end
end
