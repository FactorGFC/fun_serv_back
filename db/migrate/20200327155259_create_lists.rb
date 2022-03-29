class CreateLists < ActiveRecord::Migration[6.0]
  def change
    create_table :lists, id: :uuid do |t|
      t.string :domain, null: false
      t.string :key, null: false
      t.string :value, null: false
      t.string :description

      t.timestamps
    end
  end
end
