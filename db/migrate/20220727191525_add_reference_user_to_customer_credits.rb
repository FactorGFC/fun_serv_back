class AddReferenceUserToCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_credits, :user, type: :uuid, null: true, foreign_key: true
  end
end
