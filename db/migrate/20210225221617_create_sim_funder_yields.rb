class CreateSimFunderYields < ActiveRecord::Migration[6.0]
  def change
    create_table :sim_funder_yields, id: :uuid do |t|
      t.integer :yield_number, null: false
      t.decimal :capital, null: false, precision: 15, scale: 4
      t.decimal :gross_yield, null: false, precision: 15, scale: 4
      t.decimal :isr, null: false, precision: 15, scale: 4
      t.decimal :net_yield, null: false, precision: 15, scale: 4
      t.decimal :total, null: false, precision: 15, scale: 4
      t.decimal :payment_date, null: false
      t.string :status, null: false
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :funder, type: :uuid, null: false, foreign_key: true
      t.references :investment, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
