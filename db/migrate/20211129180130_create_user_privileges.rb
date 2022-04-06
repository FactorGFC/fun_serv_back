# frozen_string_literal: true
class CreateUserPrivileges < ActiveRecord::Migration[6.0]
  def change
    create_table :user_privileges, id: :uuid do |t|
      t.string :description, null: false
      t.string :key, null: false
      t.string :value, null: false
      t.string :documentation
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
