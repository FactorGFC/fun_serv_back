class CreateFileTypeDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :file_type_documents, id: :uuid do |t|
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :document, type: :uuid, null: false, foreign_key: true
      t.references :file_type, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
