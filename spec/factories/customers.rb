# frozen_string_literal: true
# == Schema Information
#
# Table name: customers
#
#  id                  :uuid             not null, primary key
#  assist_bonus        :decimal(15, 4)
#  attached            :string
#  benefit             :string
#  benefit_detail      :string
#  child_support       :decimal(15, 4)
#  christmas_bonus     :decimal(15, 4)
#  credit_cp           :decimal(15, 4)
#  credit_lp           :decimal(15, 4)
#  customer_type       :string           not null
#  extra1              :string
#  extra2              :string
#  extra3              :string
#  extra_expenses      :decimal(15, 4)
#  family_expenses     :decimal(15, 4)
#  food_vouchers       :decimal(15, 4)
#  house_rent          :decimal(15, 4)
#  immediate_superior  :string
#  imms                :decimal(15, 4)
#  infonavit           :decimal(15, 4)
#  insurance_discount  :decimal(15, 4)
#  job                 :string
#  name                :string           not null
#  net_expenses        :decimal(15, 4)
#  ontime_bonus        :decimal(15, 4)
#  other_income        :decimal(15, 4)
#  other_income_detail :string
#  public_charge       :string
#  public_charge_det   :string
#  relative_charge     :string
#  relative_charge_det :string
#  responsible         :string
#  responsible_detail  :string
#  salary              :decimal(15, 4)   not null
#  salary_period       :string           not null
#  savings_bank        :decimal(15, 4)
#  savings_found       :decimal(15, 4)
#  savings_found_loand :decimal(15, 4)
#  seniority           :decimal(15, 4)
#  status              :string           not null
#  taxes               :decimal(15, 4)
#  total_income        :decimal(15, 4)
#  total_savings_found :decimal(15, 4)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :uuid
#  contributor_id      :uuid             not null
#  file_type_id        :uuid
#  user_id             :uuid
#
# Indexes
#
#  index_customers_on_company_id      (company_id)
#  index_customers_on_contributor_id  (contributor_id)
#  index_customers_on_file_type_id    (file_type_id)
#  index_customers_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_id => file_types.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :customer do
    name { "Carlos Acosta" }
    customer_type { "CF" }
    status { "AC" }
    attached { "https://localhost/contrato.doc" }
    salary {"20369.20"}
    salary_period {"Quincenal"}
    other_income {"0.00"}
    net_expenses {"5734.00"}
    family_expenses {"2500.00"}
    house_rent {"0.00"}
    credit_cp {"11145.00"}
    credit_lp{"0.00"}
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    immediate_superior {"Raul Gutierrez Molinar"} 
    seniority {"2"} 
    ontime_bonus {"825.30"}
    assist_bonus {"825.30"}
    food_vouchers {"245.00"} 
    total_income {"10184.60"}
    total_savings_found {"51685.92"}
    christmas_bonus {"33132.00"} 
    taxes {"1412.00"} 
    imms {"293.71"} 
    savings_found {"1076.79"} 
    savings_found_loand {"138.75"} 
    savings_bank {""} 
    insurance_discount {""}
    child_support {""} 
    extra_expenses {""} 
    infonavit {""} 
    association :contributor, factory: :contributor
    association :user, factory: :user
    association :file_type, factory: :file_type
    association :company, factory: :company
    # association :credit_bureau, factory: :credit_bureau
  end
end
