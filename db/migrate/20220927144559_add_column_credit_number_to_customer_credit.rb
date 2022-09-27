class AddColumnCreditNumberToCustomerCredit < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits, :credit_number, :string
  end
end
