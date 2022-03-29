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
require 'rails_helper'

RSpec.describe CustomerCredit, type: :model do
  
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :status }
  it { should validate_presence_of :total_requested }
  it { should belong_to(:customer) }
end
