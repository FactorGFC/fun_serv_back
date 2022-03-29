# == Schema Information
#
# Table name: sim_funder_yields
#
#  id                :uuid             not null, primary key
#  attached          :string
#  capital           :decimal(15, 4)   not null
#  current_capital   :decimal(15, 4)   not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  gross_yield       :decimal(15, 4)   not null
#  isr               :decimal(15, 4)   not null
#  net_yield         :decimal(15, 4)   not null
#  payment_date      :date             not null
#  remaining_capital :decimal(15, 4)   not null
#  status            :string           not null
#  total             :decimal(15, 4)   not null
#  yield_number      :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  funder_id         :uuid             not null
#  investment_id     :uuid             not null
#
# Indexes
#
#  index_sim_funder_yields_on_funder_id      (funder_id)
#  index_sim_funder_yields_on_investment_id  (investment_id)
#
# Foreign Keys
#
#  fk_rails_...  (funder_id => funders.id)
#  fk_rails_...  (investment_id => investments.id)
#
FactoryBot.define do
  factory :sim_funder_yield do
    yield_number { 1 }
    remaining_capital { "200000.00" }
    capital { "1000" }
    gross_yield { "250" }
    isr { "50" }
    net_yield { "200" }
    total { "1200" }
    current_capital {"800"}
    payment_date { "2021-03-01" }
    status { "AC" }
    attached { "http://yields/74334878.pdf" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :funder, factory: :funder
    association :investment, factory: :investment
  end
end
