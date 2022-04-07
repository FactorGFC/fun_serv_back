# frozen_string_literal: true
class CreateContributorDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :contributor_documents, id: :uuid do |t|
      t.string :name, null: false
      t.string :status, null: false
      t.string :notes
      t.string :url
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :contributor, type: :uuid, null: false, foreign_key: true
      t.references :file_type_document, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
