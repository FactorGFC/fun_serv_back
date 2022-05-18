# == Schema Information
#
# Table name: payment_credits
#
#  id                 :uuid             not null, primary key
#  pc_type            :string           not null
#  total              :decimal(15, 4)   not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_credit_id :uuid             not null
#  payment_id         :uuid             not null
#
# Indexes
#
#  index_payment_credits_on_customer_credit_id  (customer_credit_id)
#  index_payment_credits_on_payment_id          (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#  fk_rails_...  (payment_id => payments.id)
#
require 'rails_helper'

RSpec.describe PaymentCredit, type: :model do
  it { should validate_presence_of :total }
  it { should validate_presence_of :pc_type}
  it { should validate_presence_of :payment}
  it { should validate_presence_of :customer_credit}
end
