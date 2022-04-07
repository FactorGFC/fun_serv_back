# frozen_string_literal: true
# == Schema Information
#
# Table name: credit_ratings
#
#  id          :uuid             not null, primary key
#  cr_type     :string
#  description :string           not null
#  extra1      :string
#  extra2      :string
#  extra3      :string
#  key         :string           not null
#  value       :decimal(15, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :credit_rating do
    key { "AA" }
    description { "Compañías de gran calidad, muy estables y de bajo riesgo" }
    value { ".50" }
    cr_type { "S&P" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
  end
end
