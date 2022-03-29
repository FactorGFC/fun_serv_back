# frozen_string_literal: true

class AddRolesRefToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :roles, type: :uuid, foreign_key: true
  end
end
