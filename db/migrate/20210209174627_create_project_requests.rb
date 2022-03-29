class CreateProjectRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :project_requests, id: :uuid do |t|
      t.string :project_type, null: false
      t.string :folio, null: false
      t.string :currency, null: false
      t.decimal :total, null: false, precision: 15, scale: 4
      t.date :request_date, null: false
      t.string :status, null: false
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :term, type: :uuid, null: false, foreign_key: true
      t.references :payment_period, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
