# frozen_string_literal: true

# == Schema Information
#
# Table name: legal_entities
#
#  id             :uuid             not null, primary key
#  business_email :string
#  business_name  :string           not null
#  email          :string
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  fiel           :boolean
#  fiscal_regime  :string           not null
#  main_activity  :string
#  mobile         :string
#  phone          :string
#  rfc            :string           not null
#  rug            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class LegalEntity < ApplicationRecord
  include Swagger::Blocks
  include Swagger::LegalEntitySchema
  has_many :contributors
  has_many :contributor_addresses, through: :contributors
  has_many :customers, through: :contributors

  validates :fiscal_regime, presence: true
  validates :rfc, presence: true, uniqueness: true
  validates :business_name, presence: true
end
