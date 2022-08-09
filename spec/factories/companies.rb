# == Schema Information
#
# Table name: companies
#
#  id               :uuid             not null, primary key
#  balance          :decimal(15, 4)
#  business_name    :string           not null
#  company_rate     :string
#  credit_available :decimal(15, 4)
#  credit_limit     :decimal(15, 4)
#  document         :string
#  sector           :string
#  start_date       :date             not null
#  subsector        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contributor_id   :uuid             not null
#
# Indexes
#
#  index_companies_on_contributor_id  (contributor_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#
FactoryBot.define do
  factory :company do
    business_name { "Bancomer" }
    start_date { "2020-05-04" }
    credit_limit { "1000000.8888" }
    credit_available { "1000000.8888" }
    balance { "0" }
    document { "Documentación" }
    sector { "Financiero" }
    subsector { "Banca" }
    company_rate {"EXTERNO"}
    association :contributor, factory: :contributor
    end
end
