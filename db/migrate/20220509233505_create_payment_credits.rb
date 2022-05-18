class CreatePaymentCredits < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_credits, id: :uuid do |t|
      t.string :pc_type, null: false
      t.decimal :total, null: false, precision: 15, scale: 4

      t.timestamps
    end
  end
end
