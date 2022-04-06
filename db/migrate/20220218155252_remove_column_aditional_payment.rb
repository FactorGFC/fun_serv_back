# frozen_string_literal: true
class RemoveColumnAditionalPayment < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_credits, :aditional_payment, :decimal
  end
end
