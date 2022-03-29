class AddYieldFixedPaymentToInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :investments, :yield_fixed_payment, :decimal, precision: 15, scale: 4, null: false
  end
end
