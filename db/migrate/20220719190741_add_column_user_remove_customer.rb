class AddColumnUserRemoveCustomer < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_credits_signatories, :customer_id
    add_reference :customer_credits_signatories, :user,  type: :uuid, foreign_key: { to_table: :users }, null: false
  end
end
