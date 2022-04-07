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
require 'rails_helper'

RSpec.describe PostalCode, type: :model do
  it { should validate_presence_of :municipality }
  it { should validate_presence_of :pc }
  it { should validate_presence_of :state }
  it { should validate_presence_of :suburb }
end
