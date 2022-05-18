class AddForeingKeysToPaymentCredits < ActiveRecord::Migration[6.0]
  def change
    add_reference :payment_credits, :payment,  type: :uuid, foreign_key: { to_table: :payments }, null: false
    add_reference :payment_credits, :customer_credit,  type: :uuid, foreign_key: { to_table: :customer_credits }, null: false
  end
end
