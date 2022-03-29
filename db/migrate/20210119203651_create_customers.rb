class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :name, null: false
      t.string :customer_type, null: false
      t.string :status, null: false
      t.string :attached
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :contributor, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
