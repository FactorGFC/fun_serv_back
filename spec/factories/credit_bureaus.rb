# == Schema Information
#
# Table name: credit_bureaus
#
#  id            :bigint           not null, primary key
#  bureau_info   :jsonb
#  bureau_report :jsonb
#  extra1        :string
#  extra2        :string
#  extra3        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bureau_id     :integer
#  customer_id   :uuid             not null
#
# Indexes
#
#  index_credit_bureaus_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
FactoryBot.define do
  factory :credit_bureau do
    bureau_info { "Clientes de gran confianza, muy estables y de bajo riesgo" }
    bureau_report { "Clientes de gran confianza, muy estables y de bajo riesgo" }
    bureau_id { "1234215" }
    
    association :customer, factory: :customer

  end
end
