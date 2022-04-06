# frozen_string_literal: true
class CreateCustomerPersonalReferences < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_personal_references, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :second_last_name, null: false
      t.string :address
      t.string :phone
      t.string :type

      t.timestamps
    end
  end
end
