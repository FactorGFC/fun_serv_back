# frozen_string_literal: true
class CreateTokens < ActiveRecord::Migration[6.0]
 def change
    create_table :tokens, id: :uuid do |t|
      t.datetime :expires_at
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :my_app, type: :uuid, null: true, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
