class AddForeignKeyCustomerCreditId < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_credits_signatories, :customer_credit_id
    add_reference :customer_credits_signatories, :customer_credit,  type: :uuid, foreign_key: { to_table: :customer_credits }, null: false
  end
end
