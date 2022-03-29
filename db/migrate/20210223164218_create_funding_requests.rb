class CreateFundingRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :funding_requests, id: :uuid do |t|
      t.decimal :total_requested, null: false, precision: 15, scale: 4
      t.decimal :total_investments, null: false, precision: 15, scale: 4
      t.decimal :balance, null: false, precision: 15, scale: 4
      t.date :funding_request_date, null: false
      t.date :funding_due_date, null: false
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :project, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
