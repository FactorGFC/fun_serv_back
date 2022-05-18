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
FactoryBot.define do
  factory :payment_credit do
    pc_type { "PAGO PROVEEDOR" }
    total { "10000" }
    association :payment, factory: :payment
    association :customer_credit, factory: :customer_credit
  end
    
end
