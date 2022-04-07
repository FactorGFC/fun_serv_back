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
class ContributorAddress < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ContributorAddressSchema
  belongs_to :municipality
  belongs_to :contributor
  belongs_to :state
  has_many :people, through: :contributors
  has_many :legal_entities, through: :contributors
  validates :street, presence: true
  validates :address_type, presence: true
  validates :external_number, presence: true
  validates :suburb, presence: true
  validates :postal_code, presence: true
  validates :contributor, presence: true
  validates :municipality, presence: true
  validates :state, presence: true
end
