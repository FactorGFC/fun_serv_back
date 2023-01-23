class AddColumnsToCustomers4 < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :relative_charge_det, :string
  end
end
