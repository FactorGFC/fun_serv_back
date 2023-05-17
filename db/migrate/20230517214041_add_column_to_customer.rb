class AddColumnToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :other_income_detail, :string
  end
end
