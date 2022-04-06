class CreateCreditAnalyses < ActiveRecord::Migration[6.0]
  def change
    create_table :credit_analyses, id: :uuid do |t|
       t.decimal :debt_rate, precision: 15, scale: 4
       t.decimal :cash_flow, precision: 15, scale: 4
       t.string  :credit_status, null: false
       t.string  :previus_credit  
       t.decimal :discounts, precision: 15, scale: 4
       t.decimal :debt_horizon, precision: 15, scale: 4
       t.date    :report_date, null: false
       t.string  :mop_key, null: false
       t.decimal :last_key, null: false, precision: 15, scale: 4
       t.string  :balance_due
       t.decimal :payment_capacity, precision: 15, scale: 4
       t.decimal :lowest_key, null: false, precision: 15, scale: 4
       t.decimal :departamental_credit,  precision: 15, scale: 4
       t.decimal :car_credit, precision: 15, scale: 4
       t.decimal :mortagage_loan, precision: 15, scale: 4
       t.decimal :other_credits, precision: 15, scale: 4
       t.decimal :accured_liabilities, precision: 15, scale: 4
       t.decimal :debt, precision: 15, scale: 4
       t.decimal :net_flow, precision: 15, scale: 4
       t.references :customer_credit, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
