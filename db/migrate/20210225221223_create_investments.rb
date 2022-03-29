class CreateInvestments < ActiveRecord::Migration[6.0]
  def change
    create_table :investments, id: :uuid do |t|
      t.decimal :total, null: false, precision: 15, scale: 4
      t.decimal :rate, null: false, precision: 15, scale: 4
      t.date :investment_date, null: false
      t.string :status, null: false
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :funding_request, type: :uuid, null: false, foreign_key: true
      t.references :funder, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
