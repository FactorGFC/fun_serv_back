# == Schema Information
#
# Table name: ext_rates
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  end_date    :date
#  key         :string           not null
#  rate_type   :string           not null
#  start_date  :date             not null
#  value       :decimal(15, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe ExtRate, type: :model do
  it { should validate_presence_of :description }
  it { should validate_presence_of :key }
  it { should validate_presence_of :rate_type }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :value }
  it { should_not allow_value('a').for(:value) }
  it { should allow_value('5.7347').for(:value) }
end
