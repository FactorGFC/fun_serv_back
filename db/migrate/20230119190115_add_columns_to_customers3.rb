class AddColumnsToCustomers3 < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :public_charge, :string
    add_column :customers, :public_charge_det, :string
    add_column :customers, :relative_charge, :string
    add_column :customers, :benefit, :string
    add_column :customers, :benefit_detail, :string
    add_column :customers, :responsible, :string
    add_column :customers, :responsible_detail, :string
  end
end
