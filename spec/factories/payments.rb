# == Schema Information
#
# Table name: payments
#
#  id                  :uuid             not null, primary key
#  amount              :decimal(15, 4)   not null
#  currency            :string           not null
#  email_cfdi          :string           not null
#  notes               :string
#  payment_date        :date             not null
#  payment_number      :string           not null
#  payment_type        :string           not null
#  voucher             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  contributor_from_id :uuid             not null
#  contributor_to_id   :uuid             not null
#
# Indexes
#
#  index_payments_on_contributor_from_id  (contributor_from_id)
#  index_payments_on_contributor_to_id    (contributor_to_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_from_id => contributors.id)
#  fk_rails_...  (contributor_to_id => contributors.id)
#
FactoryBot.define do
  factory :payment do
    payment_date { "2020-05-21" }
    payment_type { "Transferencia" }
    payment_number { "TR123456" }
    currency { "Pesos" }
    amount { "100000.50" }
    email_cfdi { "email@mail.com" }
    notes { "Depósito de COPACHISA transfereca 123456" }
    voucher { "https://localhost/vouchers/V123456789" }
    association :contributor_from
    association :contributor_to
  end
end
