# frozen_string_literal: true
# == Schema Information
#
# Table name: people
#
#  id                :uuid             not null, primary key
#  birth_country     :string
#  birthdate         :date             not null
#  birthplace        :string
#  curp              :string
#  email             :string
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  fiel              :boolean
#  first_name        :string           not null
#  fiscal_regime     :string           not null
#  gender            :string
#  housing_type      :string
#  id_type           :string
#  identification    :bigint           not null
#  imss              :bigint
#  last_name         :string           not null
#  martial_regime    :string
#  martial_status    :string
#  minior_dependents :integer
#  mobile            :string
#  nationality       :string
#  phone             :string
#  rfc               :string           not null
#  second_last_name  :string           not null
#  senior_dependents :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe Person, type: :model do
  it { should validate_presence_of :fiscal_regime }
  it { should validate_presence_of :rfc }
  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :second_last_name }
  it { should validate_presence_of :birthdate }
  it { should validate_presence_of :identification }
end
