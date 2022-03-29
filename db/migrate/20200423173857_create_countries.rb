class CreateCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :countries, id: :uuid do |t|
      t.string :sortname, null: false
      t.string :name, null: false
      t.integer :phonecode

      t.timestamps
    end
  end
end
