class CreateContributors < ActiveRecord::Migration[6.0]
  def change
    create_table :contributors, id: :uuid do |t|
      t.string :contributor_type, null: false
      t.string :bank
      t.bigint :account_number
      t.bigint :clabe
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end
