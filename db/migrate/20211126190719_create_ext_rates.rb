# frozen_string_literal: true
class CreateExtRates < ActiveRecord::Migration[6.0]
  def change
    create_table :ext_rates, id: :uuid do |t|
      t.string :key, null: false
      t.string :description, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.decimal :value, null: false, precision: 15, scale: 4
      t.string :rate_type, null: false

      t.timestamps
    end
  end
end