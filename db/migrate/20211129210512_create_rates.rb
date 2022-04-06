# frozen_string_literal: true
class CreateRates < ActiveRecord::Migration[6.0]
  def change
    create_table :rates, id: :uuid do |t|
      t.string :key, null: false
      t.string :description, null: false
      t.string :value, null: false
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :term, type: :uuid, null: false, foreign_key: true
      t.references :payment_period, type: :uuid, null: false, foreign_key: true
      t.references :credit_rating, type: :uuid, null: true, foreign_key: true

      t.timestamps
    end
  end
end
