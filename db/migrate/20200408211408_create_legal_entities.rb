class CreateLegalEntities < ActiveRecord::Migration[6.0]
  def change
    create_table :legal_entities, id: :uuid do |t|
      t.string :fiscal_regime, null: false
      t.string :rfc, null: false
      t.string :rug
      t.string :business_name, null: false
      t.string :phone
      t.string :mobile
      t.string :email
      t.string :business_email
      t.string :main_activity
      t.boolean :fiel
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end
