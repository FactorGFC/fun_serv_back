# frozen_string_literal: true
class CreateCreditRatings < ActiveRecord::Migration[6.0]
  def change
    create_table :credit_ratings, id: :uuid do |t|
      t.string :key, null: false
      t.string :description, null: false
      t.decimal :value, null: false, precision: 15, scale: 4
      t.string :cr_type
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end