# frozen_string_literal: true
class CreateRoleOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :role_options, id: :uuid do |t|

      t.timestamps
    end
  end
end