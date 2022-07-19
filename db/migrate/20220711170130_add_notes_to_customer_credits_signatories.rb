class AddNotesToCustomerCreditsSignatories < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits_signatories, :notes, :string
  end
end
