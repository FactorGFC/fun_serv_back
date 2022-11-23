# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_periods
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  extra1      :string
#  extra2      :string
#  extra3      :string
#  key         :string           not null
#  pp_type     :string
#  value       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :payment_period do
    key { "Quincenal" }
    description { "Numero de pagos al año" }
    value { 24 }
    pp_type { "2" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
  end
end
