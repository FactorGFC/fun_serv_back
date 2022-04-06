# frozen_string_literal: true
class CreatePaymentPeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_periods, id: :uuid do |t|
      t.string :key, null: false
      t.string :description, null: false
      t.integer :value, null: false
      t.string :pp_type
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end
