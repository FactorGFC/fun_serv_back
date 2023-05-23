class AddTwoColumnsToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :file_token, :string
    add_column :customers, :file_token_expiration, :string
  end
end
