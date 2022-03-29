class AddCurrentCapitalToSimFunderYield < ActiveRecord::Migration[6.0]
  def change
    add_column :sim_funder_yields, :current_capital, :decimal, precision: 15, scale: 4, null: false
  end
end
