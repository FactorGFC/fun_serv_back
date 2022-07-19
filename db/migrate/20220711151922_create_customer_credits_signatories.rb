class CreateCustomerCreditsSignatories < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_credits_signatories, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.references :customer_credit, null: false, foreign_key: true
      t.string :firmantes_token
      t.datetime :firmantes_token_expiry
      t.string :status

      t.timestamps
    end
  end
end
