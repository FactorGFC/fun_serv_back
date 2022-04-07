# frozen_string_literal: true
# == Schema Information
#
# Table name: cities
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_cities_on_state_id  (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#
FactoryBot.define do
  factory :city do
    name { 'Guerrero' }
    association :state, factory: :state
  end
end
