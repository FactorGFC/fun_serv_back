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
require 'rails_helper'

RSpec.describe SimFunderYield, type: :model do
  it { should validate_presence_of :gross_yield }
  it { should validate_presence_of :isr }
  it { should validate_presence_of :net_yield }
  it { should validate_presence_of :payment_date }
  it { should validate_presence_of :status }
  it { should validate_presence_of :total }
  it { should validate_presence_of :yield_number }
  it { should validate_presence_of :remaining_capital }
  it { should belong_to(:investment) }
  it { should belong_to(:funder) }
end
