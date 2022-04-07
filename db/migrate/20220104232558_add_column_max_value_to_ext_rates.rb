# frozen_string_literal: true
class AddColumnMaxValueToExtRates < ActiveRecord::Migration[6.0]
  def change
   add_column :ext_rates, :max_value, :decimal, null: true, precision: 15, scale: 4
  end
end
