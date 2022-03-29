class CreatePostalCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :postal_codes, id: :uuid do |t|
      t.integer :pc, null: false
      t.string :suburb_type
      t.string :suburb, null: false
      t.string :municipality, null: false
      t.string :state, null: false

      t.timestamps
    end
  end
end
