# frozen_string_literal: true
class ChangeNullTrueFromRates < ActiveRecord::Migration[6.0]
  def change
      change_column :rates, :payment_period_id, :uuid,  null: true
      change_column :rates, :term_id, :uuid, null: true
  end
end
