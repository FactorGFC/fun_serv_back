# frozen_string_literal: true
class AddRefrenceToCustomerPersonalReferences < ActiveRecord::Migration[6.0]
  def change
   add_reference :customer_personal_references, :customer, type: :uuid, null: false, foreign_key: true
  end
end
