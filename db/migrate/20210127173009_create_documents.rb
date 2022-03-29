class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :document_type, null: false
      t.string :name, null: false
      t.string :description, null: false
      t.string :validation
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.references :ext_service, type: :uuid, null: true, foreign_key: true

      t.timestamps
    end
  end
end
