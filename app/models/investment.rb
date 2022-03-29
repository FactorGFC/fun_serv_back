# == Schema Information
#
# Table name: investments
#
#  id                  :uuid             not null, primary key
#  attached            :string
#  extra1              :string
#  extra2              :string
#  extra3              :string
#  investment_date     :date             not null
#  rate                :decimal(15, 4)   not null
#  status              :string           not null
#  total               :decimal(15, 4)   not null
#  yield_fixed_payment :decimal(15, 4)   not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  funder_id           :uuid             not null
#  funding_request_id  :uuid             not null
#
# Indexes
#
#  index_investments_on_funder_id           (funder_id)
#  index_investments_on_funding_request_id  (funding_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (funder_id => funders.id)
#  fk_rails_...  (funding_request_id => funding_requests.id)
#
class Investment < ApplicationRecord
  include Swagger::Blocks
  include Swagger::InvestmentSchema
  belongs_to :funding_request
  belongs_to :funder
  has_many :sim_funder_yields, dependent: :destroy
  has_many :current_yields, -> { current_funder_yields }, class_name: 'SimFunderYield'
  has_many :pending_yields, -> { pending_funder_yields }, class_name: 'SimFunderYield'

  validates :investment_date, presence: true
  validates :status, presence: true
  validates :total, presence: true
end
