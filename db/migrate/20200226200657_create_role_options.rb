# frozen_string_literal: true

class CreateRoleOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :role_options, id: :uuid do |t|
      t.references :roles, type: :uuid, null: false, foreign_key: true
      t.references :options, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
