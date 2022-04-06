# frozen_string_literal: true
class CreateOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :options, id: :uuid do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :group
      t.string :url

      t.timestamps
    end
  end
end
