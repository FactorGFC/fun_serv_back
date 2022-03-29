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
require 'rails_helper'

RSpec.describe FundingRequest, type: :model do
  it { should validate_presence_of :balance }
  it { should validate_presence_of :funding_due_date }
  it { should validate_presence_of :funding_request_date }
  it { should validate_presence_of :total_investments }
  it { should validate_presence_of :total_requested }
  it { should belong_to(:project) }
end
