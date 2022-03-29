# == Schema Information
#
# Table name: funding_requests
#
#  id                   :uuid             not null, primary key
#  attached             :string
#  balance              :decimal(15, 4)   not null
#  extra1               :string
#  extra2               :string
#  extra3               :string
#  funding_due_date     :date             not null
#  funding_request_date :date             not null
#  status               :string           not null
#  total_investments    :decimal(15, 4)   not null
#  total_requested      :decimal(15, 4)   not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  project_id           :uuid             not null
#
# Indexes
#
#  index_funding_requests_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
FactoryBot.define do
  factory :funding_request do
    total_requested { "100000.00" }
    total_investments { "0.00" }
    balance { "100000.00" }
    funding_request_date { "2021-02-01" }
    funding_due_date { "2021-04-01" }
    status { "AC" }
    attached { "http://localhost/funding_request124654.pdf" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :project, factory: :project
    factory :funding_request_with_investments do
      total_requested { "100000.00" }
      total_investments { "0.00" }
      balance { "100000.00" }
      funding_request_date { "2021-02-01" }
      funding_due_date { "2021-04-01" }
      status { "AC" }
      attached { "http://localhost/funding_request124654.pdf" }
      extra1 { "MyString" }
      extra2 { "MyString" }
      extra3 { "MyString" }
      association :project, factory: :project
      investments { build_list :investment, 2 }
    end
  end  
end
