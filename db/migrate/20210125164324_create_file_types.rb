class CreateFileTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :file_types, id: :uuid do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :customer_type
      t.string :funder_type
      t.string :extra1
      t.string :extra2
      t.string :extra3

      t.timestamps
    end
  end
end
