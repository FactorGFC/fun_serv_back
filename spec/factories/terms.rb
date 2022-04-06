# frozen_string_literal: true
# == Schema Information
#
# Table name: terms
#
#  id           :uuid             not null, primary key
#  credit_limit :decimal(15, 4)   not null
#  description  :string           not null
#  extra1       :string
#  extra2       :string
#  extra3       :string
#  key          :string           not null
#  term_type    :string           not null
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :term do
    key { "12m" }
    description { "Doce meses" }
    value { 12 }
    term_type { "ME" }
    credit_limit { "100000.00" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
  end
end
