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
FactoryBot.define do
  factory :sim_customer_payment do
    pay_number { 1 }
    current_debt { "100000.00" }
    remaining_debt { "100000.00" }
    payment { "5000.00" }
    capital { "3500.00" }
    interests { "1000.00" }
    iva { "500.00" }
    payment_date { "2021-03-01" }
    status { "AC" }
    attached { "https://payment8768.pdf" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :customer_credit, factory: :customer_credit
  end
end
