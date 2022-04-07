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
require 'rails_helper'

RSpec.describe LegalEntity, type: :model do
  it { should validate_presence_of :fiscal_regime }
  it { should validate_presence_of :rfc }
  it { should validate_presence_of :business_name }
end
