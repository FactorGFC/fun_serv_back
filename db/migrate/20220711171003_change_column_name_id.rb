class ChangeColumnNameId < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_credits_signatories, :user_id, :user_id
    rename_column :customer_credits_signatories, :customer_credit_id, :customer_credit_id
  end
end
