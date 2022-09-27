class AddColumnsToCreditAnalyses < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_analyses, :total_amount, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :credit_type, :string
    add_column :credit_analyses, :customer_number, :string
    add_column :credit_analyses, :anual_rate, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :total_cost, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :overall_rate, :decimal, precision: 15, scale: 4
    add_column :credit_analyses, :total_debt, :decimal, precision: 15, scale: 4
  end
end
