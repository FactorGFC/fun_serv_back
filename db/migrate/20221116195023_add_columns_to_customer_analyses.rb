class AddColumnsToCustomerAnalyses < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_analyses, :total_income, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :total_expenses, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :monthly_income, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :monthly_expenses, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :payment_credit_cp, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :payment_credit_lp, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :debt_cp, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :departamentalc_debt, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :personalc_debt, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :car_debt, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :mortagage_debt, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :otherc_debt, :decimal, precision: 15, scale: 4
  end
end
