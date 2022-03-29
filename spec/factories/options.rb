# frozen_string_literal: true

# == Schema Information
#
# Table name: options
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  group       :string
#  name        :string           not null
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :option do
    name { 'Opcion 1' }
    description { 'Esta es la primer opción del menu' }
    factory :sequence_option do
      sequence(:name) { |n| "opcion#{n}" }
      description { 'Esta es la opcion n' }
    end
  end
end
