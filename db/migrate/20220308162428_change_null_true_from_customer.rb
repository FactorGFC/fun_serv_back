class ChangeNullTrueFromCustomer < ActiveRecord::Migration[6.0]
  def change
    change_column :customers, :company_id, :uuid,  null: true
  end
end
