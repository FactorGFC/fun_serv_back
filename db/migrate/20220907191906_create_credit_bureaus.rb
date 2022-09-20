class CreateCreditBureaus < ActiveRecord::Migration[6.0]
  def change
    create_table :credit_bureaus do |t|
      t.references :customer, type: :uuid, foreign_key: true, null: false
      t.integer :bureau_id
      t.jsonb :bureau_info
      t.jsonb :bureau_report

      t.timestamps
    end
  end
end




