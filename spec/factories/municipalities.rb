# == Schema Information
#
# Table name: municipalities
#
#  id               :uuid             not null, primary key
#  municipality_key :string           not null
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  state_id         :uuid             not null
#
# Indexes
#
#  index_municipalities_on_state_id  (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#
FactoryBot.define do
  factory :municipality do
    municipality_key { '08' }
    name { 'Guerrero' }
    association :state, factory: :state
  end
end
