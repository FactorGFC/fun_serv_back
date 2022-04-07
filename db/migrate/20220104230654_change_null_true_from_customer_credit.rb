# frozen_string_literal: true
class ChangeNullTrueFromCustomerCredit < ActiveRecord::Migration[6.0]
  def change
      change_column :customer_credits, :payment_period_id, :uuid,  null: true
      change_column :customer_credits, :term_id, :uuid, null: true
      change_column :customer_credits, :credit_rating_id,:uuid, null: true
    end
end
