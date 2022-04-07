# frozen_string_literal: true
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, default: ''
      t.string :password_digest, null: false, default: ''
      t.string :name, null: false, default: ''
      t.string :job
      t.string :gender
      t.string :status
      t.string :reset_password_token
      t.references :role, type: :uuid, foreign_key: true
      t.timestamps null: false
    end
  end
end
