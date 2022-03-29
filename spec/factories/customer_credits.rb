# == Schema Information
#
# Table name: customer_credits
#
#  id                 :uuid             not null, primary key
#  attached           :string
#  balance            :decimal(15, 4)   not null
#  capital            :decimal(15, 4)   not null
#  end_date           :date             not null
#  extra1             :string
#  extra2             :string
#  extra3             :string
#  fixed_payment      :decimal(15, 4)   not null
#  interests          :decimal(15, 4)   not null
#  iva                :decimal(15, 4)   not null
#  restructure_term   :integer
#  start_date         :date             not null
#  status             :string           not null
#  total_debt         :decimal(15, 4)   not null
#  total_payments     :decimal(15, 4)   not null
#  total_requested    :decimal(15, 4)   not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_id        :uuid             not null
#  project_id         :uuid
#  project_request_id :uuid
#
# Indexes
#
#  index_customer_credits_on_customer_id         (customer_id)
#  index_customer_credits_on_project_id          (project_id)
#  index_customer_credits_on_project_request_id  (project_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (project_request_id => project_requests.id)
#
FactoryBot.define do
  factory :customer_credit do
    total_requested { "100000.00" }
    capital { "100000.00" }
    interests { "20000.00" }
    iva { "5000.00" }
    total_debt { "125000.00" }
    fixed_payment { "10000.00" }
    total_payments { "0.00" }
    balance { "125000.00" }
    status { "AC" }
    start_date { "2021-02-01" }
    end_date { "2022-02-01" }
    attached { "http://credit124587.pdf" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :customer, factory: :customer
    association :project, factory: :project
  end
end
