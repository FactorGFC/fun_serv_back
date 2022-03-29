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
require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should validate_presence_of :client_rate }
  it { should validate_presence_of :currency }
  it { should validate_presence_of :entry_date }
  it { should validate_presence_of :ext_rate }
  it { should validate_presence_of :financial_cost }
  it { should validate_presence_of :folio }
  it { should validate_presence_of :funder_rate }
  it { should validate_presence_of :interests }
  it { should validate_presence_of :project_type }
  it { should validate_presence_of :status }
  it { should validate_presence_of :total }
  it { should validate_presence_of :entry_date }
  it { should validate_presence_of :status }
  it { should validate_presence_of :total }
  it { should belong_to(:credit_rating) }
  it { should belong_to(:customer) }
  it { should belong_to(:payment_period) }
  it { should belong_to(:project_request) }
  it { should belong_to(:term) }
  it { should belong_to(:user) }
end
