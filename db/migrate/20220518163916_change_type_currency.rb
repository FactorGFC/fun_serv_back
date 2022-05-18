class ChangeTypeCurrency < ActiveRecord::Migration[6.0]
  def change
    change_column :customer_credits, :currency, :string
  end
end
