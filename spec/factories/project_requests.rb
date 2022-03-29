# == Schema Information
#
# Table name: project_requests
#
#  id                :uuid             not null, primary key
#  attached          :string
#  currency          :string           not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  folio             :string           not null
#  project_type      :string           not null
#  rate              :decimal(15, 4)
#  request_date      :date             not null
#  status            :string           not null
#  total             :decimal(15, 4)   not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  customer_id       :uuid             not null
#  payment_period_id :uuid             not null
#  term_id           :uuid             not null
#  user_id           :uuid             not null
#
# Indexes
#
#  index_project_requests_on_customer_id        (customer_id)
#  index_project_requests_on_payment_period_id  (payment_period_id)
#  index_project_requests_on_term_id            (term_id)
#  index_project_requests_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :project_request do
    project_type { "CR" }
    folio { "CR10061984" }
    currency { "PE" }
    total { "100000" }
    request_date { "2021-02-01" }
    status { "ER" }
    attached { "MyString" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :customer, factory: :customer
    association :user, factory: :user
    association :term, factory: :term
    association :payment_period, factory: :payment_period
  end
end
