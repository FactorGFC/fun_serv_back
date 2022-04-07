# frozen_string_literal: true
# == Schema Information
#
# Table name: states
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  state_key  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :uuid             not null
#
# Indexes
#
#  index_states_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
FactoryBot.define do
  factory :state do
    state_key { '08' }
    name { 'Chihuahua' }
    association :country, factory: :country
    factory :state_with_cities do
      state_key { '08' }
      name { 'Chihuahua' }
      cities { build_list :city, 2 }
    end
    factory :state_with_municipalities do
      state_key { '08' }
      name { 'Chihuahua' }
      municipalities { build_list :municipality, 2 }
    end
  end
end
