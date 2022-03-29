class CreateGeneralParameters < ActiveRecord::Migration[6.0]
  def change
    create_table :general_parameters, id: :uuid do |t|
      t.string :table
      t.integer :id_table
      t.string :key, null: false
      t.string :description, null: false
      t.string :used_values
      t.string :value, null: false
      t.string :documentation

      t.timestamps
    end
  end
end
