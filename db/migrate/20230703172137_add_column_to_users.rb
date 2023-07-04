class AddColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :company_signatory, :string
  end
end
