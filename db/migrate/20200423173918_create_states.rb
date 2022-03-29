class CreateStates < ActiveRecord::Migration[6.0]
  def change
    create_table :states, id: :uuid do |t|
      t.string :name, null: false
      t.references :country, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
