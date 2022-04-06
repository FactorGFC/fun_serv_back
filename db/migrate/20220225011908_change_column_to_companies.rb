class ChangeColumnToCompanies < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :comany_rate, :company_rate
  end
end
