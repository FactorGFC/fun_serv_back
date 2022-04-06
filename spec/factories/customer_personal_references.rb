# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_personal_references
#
#  id               :uuid             not null, primary key
#  address          :string
#  first_name       :string           not null
#  last_name        :string           not null
#  phone            :string
#  reference_type   :string
#  second_last_name :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  customer_id      :uuid             not null
#
# Indexes
#
#  index_customer_personal_references_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
FactoryBot.define do
  factory :customer_personal_reference do
    first_name {"Uriel Jesus"}
    last_name {"Rios"}
    second_last_name {"Garcia"}
    address {"Puerta de Napa, Col. Puerta del Valle, CP 31627, Chihuahua, Chih"}
    phone {"6141048679"}
    reference_type {"Amigo"}
    association :customer, factory: :customer
  end
end
