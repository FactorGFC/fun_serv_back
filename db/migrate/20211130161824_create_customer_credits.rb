# frozen_string_literal: true
class CreateCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_credits, id: :uuid do |t|
      t.decimal :total_requested, null: false, precision: 15, scale: 4
      t.decimal :capital, null: false, precision: 15, scale: 4
      t.decimal :interests, null: false, precision: 15, scale: 4
      t.decimal :iva, null: false, precision: 15, scale: 4
      t.decimal :total_debt, null: false, precision: 15, scale: 4
      t.decimal :total_payments, null: false, precision: 15, scale: 4
      t.decimal :balance, null: false, precision: 15, scale: 4
      t.decimal :fixed_payment, null: false, precision: 15, scale: 4
      t.string :status, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :restructure_term
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.references :payment_period, type: :uuid, null: false, foreign_key: true
      t.references :term, type: :uuid, null: false, foreign_key: true
      t.references :credit_rating, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
