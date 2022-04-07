# frozen_string_literal: true
class CreateMunicipalities < ActiveRecord::Migration[6.0]
  def change
    create_table :municipalities, id: :uuid do |t|
      t.string :municipality_key, null: false
      t.string :name, null: false
      t.references :state, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
