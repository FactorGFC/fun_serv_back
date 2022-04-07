# frozen_string_literal: true
class ChangeColumnToPersonalReferences < ActiveRecord::Migration[6.0]
  def change
   rename_column :customer_personal_references, :type, :reference_type
  end
end
