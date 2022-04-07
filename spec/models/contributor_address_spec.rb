# frozen_string_literal: true
# == Schema Information
#
# Table name: contributor_addresses
#
#  id                :uuid             not null, primary key
#  address_reference :string
#  address_type      :string           not null
#  apartment_number  :string
#  external_number   :integer          not null
#  postal_code       :integer          not null
#  street            :string           not null
#  suburb            :string           not null
#  suburb_type       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  contributor_id    :uuid             not null
#  municipality_id   :uuid             not null
#  state_id          :uuid             not null
#
# Indexes
#
#  index_contributor_addresses_on_contributor_id   (contributor_id)
#  index_contributor_addresses_on_municipality_id  (municipality_id)
#  index_contributor_addresses_on_state_id         (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (municipality_id => municipalities.id)
#  fk_rails_...  (state_id => states.id)
#
require 'rails_helper'

RSpec.describe ContributorAddress, type: :model do
  it { should validate_presence_of :street }
  it { should validate_presence_of :address_type }
  it { should validate_presence_of :external_number }  
  it { should validate_presence_of :suburb }
  it { should validate_presence_of :postal_code }
  it { should validate_presence_of :contributor }
  it { should validate_presence_of :municipality }
  it { should validate_presence_of :state }
end
