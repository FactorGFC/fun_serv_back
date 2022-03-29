class RenameInterestCustomerCredit < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_credits, :interest, :interests
  end
end
