class ChangeTypeCompanyRate < ActiveRecord::Migration[6.0]
  def change
    change_column :companies, :company_rate, :string
  end
end
