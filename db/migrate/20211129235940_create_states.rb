# frozen_string_literal: true
class CreateStates < ActiveRecord::Migration[6.0]
 def change
    create_table :states, id: :uuid do |t|
      t.string :name, null: false
      t.string :state_key, null: false
      t.references :country, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
