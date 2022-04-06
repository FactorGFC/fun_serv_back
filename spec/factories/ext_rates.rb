# frozen_string_literal: true
# == Schema Information
#
# Table name: ext_rates
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  end_date    :date
#  key         :string           not null
#  max_value   :decimal(15, 4)
#  rate_type   :string           not null
#  start_date  :date             not null
#  value       :decimal(15, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :ext_rate do
    key { "tiie_28dias" }
    description { "Tasa de interés interbancaria a 28 días" }
    start_date { "2020-06-12" }
    end_date { "2020-06-12" }
    value { "5.7347" }
    rate_type { "porcentaje" }
    max_value { "" }
  end
end
