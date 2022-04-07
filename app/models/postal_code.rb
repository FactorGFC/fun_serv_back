# frozen_string_literal: true

# == Schema Information
#
# Table name: postal_codes
#
#  id           :uuid             not null, primary key
#  municipality :string           not null
#  pc           :integer          not null
#  state        :string           not null
#  suburb       :string           not null
#  suburb_type  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_postal_codes_on_pc  (pc)
#
class PostalCode < ApplicationRecord
  include Swagger::Blocks
  include Swagger::PostalCodeSchema
  validates :municipality, presence: true
  validates :pc, presence: true
  validates :state, presence: true
  validates :suburb, presence: true
end
