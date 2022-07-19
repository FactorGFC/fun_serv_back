class ChangeColumnTypes < ActiveRecord::Migration[6.0]
  def change
    change_table :customer_credits_signatories do |t|
      t.change :customer_id, :string
      t.change :customer_credit_id, :string
    end
  end
end
