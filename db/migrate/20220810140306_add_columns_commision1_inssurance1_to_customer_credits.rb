class AddColumnsCommision1Inssurance1ToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits, :insurance1, :decimal, precision: 15, scale: 4
    add_column :customer_credits, :commission1, :decimal, precision: 15, scale: 4
  end
end
