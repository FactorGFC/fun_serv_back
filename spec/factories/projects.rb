# == Schema Information
#
# Table name: projects
#
#  id                 :uuid             not null, primary key
#  attached           :string
#  client_rate        :decimal(15, 4)   not null
#  currency           :string           not null
#  entry_date         :date             not null
#  ext_rate           :decimal(15, 4)   not null
#  extra1             :string
#  extra2             :string
#  extra3             :string
#  financial_cost     :decimal(15, 4)   not null
#  folio              :string           not null
#  funder_rate        :decimal(15, 4)   not null
#  interests          :decimal(15, 4)   not null
#  project_type       :string           not null
#  status             :string           not null
#  total              :decimal(15, 4)   not null
#  used_date          :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  credit_rating_id   :uuid             not null
#  customer_id        :uuid             not null
#  payment_period_id  :uuid             not null
#  project_request_id :uuid             not null
#  term_id            :uuid             not null
#  user_id            :uuid             not null
#
# Indexes
#
#  index_projects_on_credit_rating_id    (credit_rating_id)
#  index_projects_on_customer_id         (customer_id)
#  index_projects_on_payment_period_id   (payment_period_id)
#  index_projects_on_project_request_id  (project_request_id)
#  index_projects_on_term_id             (term_id)
#  index_projects_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (project_request_id => project_requests.id)
#  fk_rails_...  (term_id => terms.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :project do
    project_type { "CR" }
    folio { "CR20210102" }
    client_rate { "18.50" }
    funder_rate { "13.50" }
    ext_rate { "5.60" }
    total { "100000.00" }
    interests { "1125.00" }
    financial_cost { "6.00" }
    currency { "MN" }
    entry_date { "2020-02-01" }
    used_date { "2020-04-01" }
    status { "EF" }
    attached { "http://localhost/contrato.pdf" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :customer, factory: :customer
    association :user, factory: :user
    association :project_request, factory: :project_request
    association :term, factory: :term
    association :payment_period, factory: :payment_period
    association :credit_rating, factory: :credit_rating
  end
end
