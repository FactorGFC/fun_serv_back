class CreateExtServices < ActiveRecord::Migration[6.0]
  def change
    create_table :ext_services, id: :uuid do |t|
      t.string :supplier, null: false
      t.string :user, null: false
      t.string :api_key
      t.string :token
      t.string :url, null: false
      t.string :rule
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end
