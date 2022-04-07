# frozen_string_literal: true
class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :name, null: false
      t.decimal :salary, null: false,  precision: 15, scale: 4
      t.string :salary_period, null: false
      t.string :customer_type, null: false
      t.string :status, null: false
      t.bigint :bank_account, null: false
      t.string :bank, null: false
      t.bigint :clabe_number, null: false
      t.decimal :other_income,  precision: 15, scale: 4 
      t.decimal :net_expenses,  precision: 15, scale: 4
      t.decimal :family_expenses,  precision: 15, scale: 4
      t.decimal :house_rent,  precision: 15, scale: 4
      t.decimal :credit_cp,  precision: 15, scale: 4
      t.decimal :credit_lp,  precision: 15, scale: 4
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :contributor, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: true, foreign_key: true
      t.references :file_type, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end