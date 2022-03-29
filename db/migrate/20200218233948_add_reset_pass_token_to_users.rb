# frozen_string_literal: true

class AddResetPassTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reset_password_token, :string
  end
end
