class AddColumn < ActiveRecord::Migration[6.0]
  def change
    add_column.references :customer_credits_signatories, :user, foreign_key: true
  end
end
