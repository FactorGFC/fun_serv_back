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
class FundingRequest < ApplicationRecord
  include Swagger::Blocks
  include Swagger::FundingRequestSchema
  belongs_to :project
  has_many :investments

  validates :balance, presence: true
  validates :funding_due_date, presence: true
  validates :funding_request_date, presence: true
  validates :total_investments, presence: true
  validates :total_requested, presence: true
end
