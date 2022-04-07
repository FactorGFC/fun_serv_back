# frozen_string_literal: true
class AddColumnsToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :immediate_superior,   :string
    add_column :customers, :seniority,            :decimal, precision: 15, scale: 4
    add_column :customers, :ontime_bonus,         :decimal, precision: 15, scale: 4
    add_column :customers, :assist_bonus,         :decimal, precision: 15, scale: 4
    add_column :customers, :food_vouchers,        :decimal, precision: 15, scale: 4
    add_column :customers, :total_income,         :decimal, precision: 15, scale: 4
    add_column :customers, :total_savings_found,  :decimal, precision: 15, scale: 4
    add_column :customers, :christmas_bonus,      :decimal, precision: 15, scale: 4
    add_column :customers, :taxes,                :decimal, precision: 15, scale: 4
    add_column :customers, :imms,                 :decimal, precision: 15, scale: 4
    add_column :customers, :savings_found,        :decimal, precision: 15, scale: 4
    add_column :customers, :savings_found_loand,  :decimal, precision: 15, scale: 4
    add_column :customers, :savings_bank,         :decimal, precision: 15, scale: 4
    add_column :customers, :insurance_discount,   :decimal, precision: 15, scale: 4
    add_column :customers, :child_support,        :decimal, precision: 15, scale: 4
    add_column :customers, :extra_expenses,       :decimal, precision: 15, scale: 4
    add_column :customers, :infonavit,            :decimal, precision: 15, scale: 4
    add_column :customers, :departamental_credit, :decimal, precision: 15, scale: 4
    add_column :customers, :car_credit,           :decimal, precision: 15, scale: 4
    add_column :customers, :mortagage_loan,       :decimal, precision: 15, scale: 4
    add_column :customers, :other_credits,        :decimal, precision: 15, scale: 4
    add_column :customers, :accured_liabilities,  :decimal, precision: 15, scale: 4
    add_column :customers, :debt,                 :decimal, precision: 15, scale: 4
    add_column :customers, :net_flow,             :decimal, precision: 15, scale: 4

  end
end
