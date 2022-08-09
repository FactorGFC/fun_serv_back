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
    key { "Iva_16" }
    description { "Taza de empleados de factor" }
    start_date { "2022-01-01" }
    end_date { "2022-12-31" }
    value { "12.5" }
    rate_type { "IVA" }
    max_value { "" }
    
    factory :er_factor do
      key { "EXTERNO" }
      description { "Taza de empleados de factor" }
      start_date { "2022-01-01" }
      end_date { "2022-12-31" }
      value { "1" }
      rate_type { "GPA" }
      max_value { "" }
     end
     factory :er_externo do
      key { "FAC" }
      description { "Comision por apertura para GPA" }
      start_date { "2022-01-01" }
      end_date { "2022-12-31" }
      value { "1" }
      rate_type { "EXT_ONE_YEARS" }
      max_value { "" }
     end
    end
  end
 
  
  

