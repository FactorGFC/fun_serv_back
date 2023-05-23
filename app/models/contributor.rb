# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id               :uuid             not null, primary key
#  account_number   :string
#  bank             :string
#  clabe            :string
#  contributor_type :string           not null
#  extra1           :string
#  extra2           :string
#  extra3           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  legal_entity_id  :uuid
#  person_id        :uuid
#
# Indexes
#
#  index_contributors_on_legal_entity_id  (legal_entity_id)
#  index_contributors_on_person_id        (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_entity_id => legal_entities.id)
#  fk_rails_...  (person_id => people.id)
#
class Contributor < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ContributorSchema
  has_many :contributor_addresses
  has_many :customers
  has_many :companies
  has_many :contributor_documents
  belongs_to :person, optional: true
  belongs_to :legal_entity, optional: true
  validates_uniqueness_of :person, allow_nil: true
  validates_uniqueness_of :legal_entity, allow_nil: true
  validates :contributor_type, presence: true
  validates :account_number, length: { maximum: 18 }
  validates :clabe, length: { maximum: 18 }
end
