# == Schema Information
#
# Table name: credit_analyses
#
#  id                   :uuid             not null, primary key
#  accured_liabilities  :decimal(15, 4)
#  anual_rate           :decimal(15, 4)
#  balance_due          :string
#  car_credit           :decimal(15, 4)
#  cash_flow            :decimal(15, 4)
#  credit_status        :string           not null
#  credit_type          :string
#  customer_number      :string
#  debt                 :decimal(15, 4)
#  debt_horizon         :decimal(15, 4)
#  debt_rate            :decimal(15, 4)
#  departamental_credit :decimal(15, 4)
#  discounts            :decimal(15, 4)
#  last_key             :decimal(15, 4)   not null
#  lowest_key           :decimal(15, 4)   not null
#  mop_key              :string           not null
#  mortagage_loan       :decimal(15, 4)
#  net_flow             :decimal(15, 4)
#  other_credits        :decimal(15, 4)
#  overall_rate         :decimal(15, 4)
#  payment_capacity     :decimal(15, 4)
#  previus_credit       :string
#  report_date          :date             not null
#  total_amount         :decimal(15, 4)
#  total_cost           :decimal(15, 4)
#  total_debt           :decimal(15, 4)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  customer_credit_id   :uuid             not null
#
# Indexes
#
#  index_credit_analyses_on_customer_credit_id  (customer_credit_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#
require 'rails_helper'

RSpec.describe CreditAnalysis, type: :model do
  it { should validate_presence_of :credit_status }
  it { should validate_presence_of :report_date }
  it { should validate_presence_of :mop_key }
  it { should validate_presence_of :last_key }
  it { should validate_presence_of :lowest_key }
end
