# frozen_string_literal: true
# == Schema Information
#
# Table name: file_types
#
#  id            :uuid             not null, primary key
#  customer_type :string
#  description   :string           not null
#  extra1        :string
#  extra2        :string
#  extra3        :string
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :file_type do
    name { "Expendiente inversionista PF" }
    description { "Expendiente requerido para un inversionista que es una persona física" }
    customer_type { "CF" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
  end
end
