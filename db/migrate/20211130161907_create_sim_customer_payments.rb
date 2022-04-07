# frozen_string_literal: true
class CreateSimCustomerPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :sim_customer_payments, id: :uuid do |t|
      t.integer :pay_number, null: false
      t.decimal :current_debt, null: false, precision: 15, scale: 4
      t.decimal :remaining_debt, null: false, precision: 15, scale: 4
      t.decimal :payment, null: false, precision: 15, scale: 4
      t.decimal :capital, null: false, precision: 15, scale: 4
      t.decimal :interests, null: false, precision: 15, scale: 4
      t.decimal :iva, null: false, precision: 15, scale: 4
      t.date :payment_date, null: false
      t.string :status, null: false
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :customer_credit, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end

