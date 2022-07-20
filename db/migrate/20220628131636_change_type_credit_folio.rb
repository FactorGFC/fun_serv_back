class ChangeTypeCreditFolio < ActiveRecord::Migration[6.0]
  def change
    change_column :customer_credits, :credit_folio, :string
  end
end
