class AddRemainingCapitalToSimFunderYields < ActiveRecord::Migration[6.0]
  def change
    add_column :sim_funder_yields, :remaining_capital, :decimal, precision: 15, scale: 4, null: false
  end
end
