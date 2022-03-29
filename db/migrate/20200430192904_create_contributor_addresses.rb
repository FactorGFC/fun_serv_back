class CreateContributorAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :contributor_addresses, id: :uuid do |t|
      t.string :address_type, null: false
      t.string :suburb, null: false
      t.string :suburb_type
      t.string :street, null: false
      t.integer :external_number, null: false
      t.string :apartment_number
      t.integer :postal_code, null: false
      t.string :address_reference
      t.references :state, type: :uuid, null: false, foreign_key: true
      t.references :municipality, type: :uuid, null: false, foreign_key: true
      t.references :contributor, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
