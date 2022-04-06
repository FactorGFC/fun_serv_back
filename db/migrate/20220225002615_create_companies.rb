class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies, id: :uuid do |t|
      t.string :business_name, null: false
      t.date :start_date, null: false
      t.decimal :credit_limit, precision: 15, scale: 4
      t.decimal :credit_available, precision: 15, scale: 4
      t.decimal :balance, precision: 15, scale: 4
      t.string :document
      t.string :sector
      t.string :subsector
      t.decimal :comany_rate
      t.references :contributor, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
