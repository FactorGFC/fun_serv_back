# frozen_string_literal: true
class AddRolesRefAndUsersRefToRoleOptions < ActiveRecord::Migration[6.0]
  def change
      add_reference :role_options, :role, type: :uuid, null: false, foreign_key: true
      add_reference :role_options, :option, type: :uuid, null: false, foreign_key: true
  end
end
