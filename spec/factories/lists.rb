# frozen_string_literal: true
# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  description :string
#  domain      :string           not null
#  key         :string           not null
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lists_on_domain_and_key  (domain,key) UNIQUE
#

FactoryBot.define do
  factory :list do
    domain { "usuario.estatus" }
    sequence(:key) { |n| "AC#{n}" }
    value { "Activo" }
    description { "Estatus activo para la tabla de usuarios" }
  end
end
