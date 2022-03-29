# == Schema Information
#
# Table name: sim_customer_payments
#
#  id                 :uuid             not null, primary key
#  attached           :string
#  capital            :decimal(15, 4)   not null
#  current_debt       :decimal(15, 4)   not null
#  extra1             :string
#  extra2             :string
#  extra3             :string
#  interests          :decimal(15, 4)   not null
#  iva                :decimal(15, 4)   not null
#  pay_number         :integer          not null
#  payment            :decimal(15, 4)   not null
#  payment_date       :date
#  remaining_debt     :decimal(15, 4)   not null
#  status             :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_credit_id :uuid             not null
#
# Indexes
#
#  index_sim_customer_payments_on_customer_credit_id  (customer_credit_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#
require 'rails_helper'

RSpec.describe SimCustomerPayment, type: :model do
  it { should validate_presence_of :capital }
  it { should validate_presence_of :interests }
  it { should validate_presence_of :iva }
  it { should validate_presence_of :pay_number }
  it { should validate_presence_of :payment }
  it { should validate_presence_of :payment_date }
  it { should validate_presence_of :current_debt }
  it { should validate_presence_of :remaining_debt }
  it { should validate_presence_of :status }
  it { should belong_to(:customer_credit) }
end
