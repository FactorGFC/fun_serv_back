# == Schema Information
#
# Table name: sim_funder_yields
#
#  id                :uuid             not null, primary key
#  attached          :string
#  capital           :decimal(15, 4)   not null
#  current_capital   :decimal(15, 4)   not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  gross_yield       :decimal(15, 4)   not null
#  isr               :decimal(15, 4)   not null
#  net_yield         :decimal(15, 4)   not null
#  payment_date      :date             not null
#  remaining_capital :decimal(15, 4)   not null
#  status            :string           not null
#  total             :decimal(15, 4)   not null
#  yield_number      :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  funder_id         :uuid             not null
#  investment_id     :uuid             not null
#
# Indexes
#
#  index_sim_funder_yields_on_funder_id      (funder_id)
#  index_sim_funder_yields_on_investment_id  (investment_id)
#
# Foreign Keys
#
#  fk_rails_...  (funder_id => funders.id)
#  fk_rails_...  (investment_id => investments.id)
#
class SimFunderYield < ApplicationRecord
  include Swagger::Blocks
  include Swagger::SimFunderYieldSchema
  belongs_to :funder
  belongs_to :investment
  scope :current_funder_yields, -> { where('status != ?', 'CA').order('yield_number') }
  scope :pending_funder_yields, -> { where('status = ?', 'PE').order('yield_number') }

  validates :gross_yield, presence: true
  validates :isr, presence: true
  validates :net_yield, presence: true
  validates :payment_date, presence: true
  validates :status, presence: true
  validates :total, presence: true
  validates :yield_number, presence: true
  validates :remaining_capital, presence: true
end
