# frozen_string_literal: true
class CreateCities < ActiveRecord::Migration[6.0]
  def change
    create_table :cities, id: :uuid do |t|
      t.string :name, null: false
      t.references :state, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end