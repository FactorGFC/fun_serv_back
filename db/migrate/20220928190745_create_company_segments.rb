class CreateCompanySegments < ActiveRecord::Migration[6.0]
  def change
    create_table :company_segments, id: :uuid do |t|
      t.string :key, null: false
      t.decimal :company_rate, precision: 15, scale: 4, null: false
      t.decimal :credit_limit, precision: 15, scale: 4, null: false
      t.decimal :max_period, precision: 15, scale: 4, null: false
      t.decimal :commission, precision: 15, scale: 4
      t.string :currency
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
