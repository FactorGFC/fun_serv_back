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
    key { "Mensual" }
    description { "Pago Mensual" }
    value { 12 }
    pp_type { "Numero de pagos en el año" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
  end
end
