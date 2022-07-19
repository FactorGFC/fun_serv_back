class AddColumnUserRemoveCustomer < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_credits_signatories, :customer_id

  end
end
