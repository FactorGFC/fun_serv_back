# frozen_string_literal: true
class RemoveColumnsFromCustomers < ActiveRecord::Migration[6.0]
  def change
  remove_column :customers, :bank_account
  remove_column :customers, :bank
  remove_column :customers, :clabe_number
  end
end
