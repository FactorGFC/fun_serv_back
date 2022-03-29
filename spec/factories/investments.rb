# == Schema Information
#
# Table name: investments
#
#  id                  :uuid             not null, primary key
#  attached            :string
#  extra1              :string
#  extra2              :string
#  extra3              :string
#  investment_date     :date             not null
#  rate                :decimal(15, 4)   not null
#  status              :string           not null
#  total               :decimal(15, 4)   not null
#  yield_fixed_payment :decimal(15, 4)   not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  funder_id           :uuid             not null
#  funding_request_id  :uuid             not null
#
# Indexes
#
#  index_investments_on_funder_id           (funder_id)
#  index_investments_on_funding_request_id  (funding_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (funder_id => funders.id)
#  fk_rails_...  (funding_request_id => funding_requests.id)
#
FactoryBot.define do
  factory :investment do
    total { "100000" }
    rate { "13.50" }
    investment_date { "2021-02-01" }
    status { "AC" }
    attached { "http://investments/89898789789.pdf" }
    yield_fixed_payment { "100" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :funding_request, factory: :funding_request
    association :funder, factory: :funder        
  end
end
