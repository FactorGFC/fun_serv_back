class AddRestructureTermToCustomerCredit < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_credits, :restructure_term, :integer
  end
end
