class AddRefrenceCompanyToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_reference :customers, :company, type: :uuid, null: false, foreign_key: true
  end
end
