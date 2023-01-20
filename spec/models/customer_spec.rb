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
#  public_charge       :string
#  public_charge_det   :string
#  relative_charge     :string
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
require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should validate_presence_of :customer_type }
  it { should validate_presence_of :name }
  it { should validate_presence_of :status }
  it { should validate_presence_of :salary }
  it { should validate_presence_of :salary_period }
  it { should belong_to(:contributor) }
  it { should belong_to(:user).optional }
  it { should belong_to(:file_type).optional}
end
