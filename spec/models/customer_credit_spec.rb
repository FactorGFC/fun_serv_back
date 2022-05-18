# frozen_string_literal: true
# == Schema Information
#
# Table name: customer_credits
#
#  id                :uuid             not null, primary key
#  amount_allowed    :decimal(15, 4)
#  attached          :string
#  balance           :decimal(15, 4)   not null
#  capital           :decimal(15, 4)   not null
#  credit_folio      :decimal(15, 4)
#  currency          :string
#  debt_time         :decimal(15, 4)
#  destination       :string
#  end_date          :date             not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  fixed_payment     :decimal(15, 4)   not null
#  interests         :decimal(15, 4)   not null
#  iva               :decimal(15, 4)   not null
#  iva_percent       :decimal(15, 4)
#  rate              :decimal(, )      not null
#  restructure_term  :integer
#  start_date        :date             not null
#  status            :string           not null
#  time_allowed      :decimal(15, 4)
#  total_debt        :decimal(15, 4)   not null
#  total_payments    :decimal(15, 4)   not null
#  total_requested   :decimal(15, 4)   not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  credit_rating_id  :uuid
#  customer_id       :uuid             not null
#  payment_period_id :uuid
#  term_id           :uuid
#
# Indexes
#
#  index_customer_credits_on_credit_rating_id   (credit_rating_id)
#  index_customer_credits_on_customer_id        (customer_id)
#  index_customer_credits_on_payment_period_id  (payment_period_id)
#  index_customer_credits_on_term_id            (term_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#
require 'rails_helper'

RSpec.describe CustomerCredit, type: :model do
  
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :status }
  it { should validate_presence_of :total_requested }
  it { should validate_presence_of :capital }
  it { should validate_presence_of :interests }
  it { should validate_presence_of :iva }
  it { should validate_presence_of :total_debt }
  it { should validate_presence_of :total_payments }
  it { should validate_presence_of :balance }
  it { should validate_presence_of :fixed_payment }
  it { should validate_presence_of :rate }
  it { should belong_to(:customer) }
  it { should belong_to(:payment_period) }
  it { should belong_to(:term) }
  it { should belong_to(:credit_rating) }
end
