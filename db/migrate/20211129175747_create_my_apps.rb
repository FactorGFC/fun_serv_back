# frozen_string_literal: true
class CreateMyApps < ActiveRecord::Migration[6.0]
  def change
    create_table :my_apps, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :title
      t.string :app_id
      t.string :javascript_origins
      t.string :secret_key

      t.timestamps
    end
  end
end