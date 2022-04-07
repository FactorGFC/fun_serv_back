class AddColumnIvaPercentToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
   add_column :customer_credits, :iva_percent, :decimal, null: true, precision: 15, scale: 4
  end
end
