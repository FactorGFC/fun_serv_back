# == Schema Information
#
# Table name: credit_analyses
#
#  id                   :uuid             not null, primary key
#  accured_liabilities  :decimal(15, 4)
#  anual_rate           :decimal(15, 4)
#  balance_due          :string
#  car_credit           :decimal(15, 4)
#  car_debt             :decimal(15, 4)
#  cash_flow            :decimal(15, 4)
#  credit_status        :string           not null
#  credit_type          :string
#  customer_number      :string
#  debt                 :decimal(15, 4)
#  debt_cp              :decimal(15, 4)
#  debt_horizon         :decimal(15, 4)
#  debt_rate            :decimal(15, 4)
#  departamental_credit :decimal(15, 4)
#  departamentalc_debt  :decimal(15, 4)
#  discounts            :decimal(15, 4)
#  last_key             :decimal(15, 4)   not null
#  lowest_key           :decimal(15, 4)   not null
#  monthly_expenses     :decimal(15, 4)
#  monthly_income       :decimal(15, 4)
#  mop_key              :string           not null
#  mortagage_debt       :decimal(15, 4)
#  mortagage_loan       :decimal(15, 4)
#  net_flow             :decimal(15, 4)
#  other_credits        :decimal(15, 4)
#  otherc_debt          :decimal(15, 4)
#  overall_rate         :decimal(15, 4)
#  payment_capacity     :decimal(15, 4)
#  payment_credit_cp    :decimal(15, 4)
#  payment_credit_lp    :decimal(15, 4)
#  personalc_debt       :decimal(15, 4)
#  previus_credit       :string
#  report_date          :date             not null
#  total_amount         :decimal(15, 4)
#  total_cost           :decimal(15, 4)
#  total_debt           :decimal(15, 4)
#  total_expenses       :decimal(15, 4)
#  total_income         :decimal(15, 4)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  customer_credit_id   :uuid             not null
#
# Indexes
#
#  index_credit_analyses_on_customer_credit_id  (customer_credit_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#
FactoryBot.define do
  factory :credit_analysis do
    debt_rate {"8.45"}
    cash_flow {"100.53"}
    credit_status {"Bueno"}
    previus_credit {"NO"}
    discounts {"20"}
    debt_horizon {"3.0"}
    report_date {"2022-05-01"}
    mop_key {"NO"}
    last_key {"1"}
    balance_due {"NO"}
    payment_capacity {"65.29"}
    lowest_key {"1"}
    departamental_credit {""}
    car_credit {""}
    mortagage_loan {""} 
    other_credits {""} 
    accured_liabilities {"11145.00"} 
    debt {""} 
    net_flow {"2867.25"}
    total_income {"1234.5"} 
    total_expenses {"1234.5"} 
    monthly_income {"1234.5"} 
    monthly_expenses {"1234.5"} 
    payment_credit_cp {"1234.5"} 
    payment_credit_lp {"1234.5"} 
    debt_cp {"1234.5"} 
    departamentalc_debt {"1234.5"} 
    personalc_debt {"1234.5"} 
    car_debt {"1234.5"} 
    mortagage_debt {"1234.5"} 
    otherc_debt {"1234.5"} 

    association :customer_credit, factory: :customer_credit
  end
end
