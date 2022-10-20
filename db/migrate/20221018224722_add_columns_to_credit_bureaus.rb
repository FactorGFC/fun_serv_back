class AddColumnsToCreditBureaus < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_bureaus, :extra1, :string
    add_column :credit_bureaus, :extra2, :string
    add_column :credit_bureaus, :extra3, :string
  end
end