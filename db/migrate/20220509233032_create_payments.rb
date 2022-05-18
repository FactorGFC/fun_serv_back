class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.date :payment_date, null: false
      t.string :payment_type, null: false
      t.string :payment_number, null: false
      t.string :currency, null: false
      t.decimal :amount, null: false, precision: 15, scale: 4
      t.string :email_cfdi, null: false
      t.string :notes
      t.string :voucher

      t.timestamps
    end
  end
end
