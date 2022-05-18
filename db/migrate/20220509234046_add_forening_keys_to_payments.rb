class AddForeningKeysToPayments < ActiveRecord::Migration[6.0]
  def change
    add_reference :payments, :contributor_from,  type: :uuid, foreign_key: { to_table: :contributors }, null: false 
    add_reference :payments, :contributor_to,  type: :uuid, foreign_key: { to_table: :contributors }, null: false
  end
end
