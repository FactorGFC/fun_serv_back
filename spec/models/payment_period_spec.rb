# == Schema Information
#
# Table name: payment_periods
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  extra1      :string
#  extra2      :string
#  extra3      :string
#  key         :string           not null
#  pp_type     :string
#  value       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe PaymentPeriod, type: :model do
  it { should validate_presence_of :description }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }
end
