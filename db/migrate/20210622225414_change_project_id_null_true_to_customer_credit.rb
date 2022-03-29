class ChangeProjectIdNullTrueToCustomerCredit < ActiveRecord::Migration[6.0]
  def change
    change_column :customer_credits, :project_id, :uuid, null: true
  end
end
