class CreatePeople < ActiveRecord::Migration[6.0]
  def change
    create_table :people, id: :uuid do |t|
      t.string :fiscal_regime, null: false
      t.string :rfc, null: false
      t.string :curp
      t.integer :imss
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :second_last_name, null: false
      t.string :gender
      t.string :nationality
      t.string :birth_country
      t.string :birthplace
      t.date :birthdate, null: false
      t.string :martial_status
      t.string :id_type
      t.integer :identification, null: false
      t.string :phone
      t.string :mobile
      t.string :email
      t.boolean :fiel
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end
