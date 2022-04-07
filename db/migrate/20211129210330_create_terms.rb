# frozen_string_literal: true
class CreateTerms < ActiveRecord::Migration[6.0]
 def change
    create_table :terms, id: :uuid do |t|
      t.string :key, null: false
      t.string :description, null: false
      t.integer :value, null: false
      t.string :term_type, null: false
      t.decimal :credit_limit, null: false, precision: 15, scale: 4
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end