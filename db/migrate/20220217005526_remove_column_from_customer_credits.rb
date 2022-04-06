# frozen_string_literal: true
class RemoveColumnFromCustomerCredits < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_credits, :insurance, :decimal
    remove_column :customer_credits, :commission, :decimal
    remove_column :customer_credits, :payment_capacity, :decimal
  end
end
