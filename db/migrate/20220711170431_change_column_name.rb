class ChangeColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_credits_signatories, :firmantes_token, :signatory_token
    rename_column :customer_credits_signatories, :firmantes_token_expiry, :signatory_token_expiration
  end
end
