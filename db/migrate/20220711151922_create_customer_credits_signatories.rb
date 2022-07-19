class CreateCustomerCreditsSignatories < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_credits_signatories, id: :uuid do |t|
      # t.references :user_id, null: false, foreign_key: true
      add_reference :customer_credits_signatories, :user,  type: :uuid, foreign_key: { to_table: :users }, null: false
      # t.references :customer_credit_id, null: false, foreign_key: true
      add_reference :customer_credits_signatories, :customer_credit,  type: :uuid, foreign_key: { to_table: :customer_credits }, null: false
      t.string :firmantes_token
      t.datetime :firmantes_token_expiry
      t.string :status

      t.timestamps
    end
  end
end
