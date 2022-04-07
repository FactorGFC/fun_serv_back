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
FactoryBot.define do
  factory :postal_code do
    pc { 99999 }
    suburb_type { "Colonia" }
    suburb { "Manuel de Sáenz" }
    municipality { "Sáenz" }
    state { "Chihuahua" }
  end
end
