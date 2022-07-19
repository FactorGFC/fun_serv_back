class ChangeColumnNameUserId < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_credits_signatories, :user_id, :customer_id
  end
end
