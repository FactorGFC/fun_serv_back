# == Schema Information
#
# Table name: credit_ratings
#
#  id          :uuid             not null, primary key
#  cr_type     :string
#  description :string           not null
#  extra1      :string
#  extra2      :string
#  extra3      :string
#  key         :string           not null
#  value       :decimal(15, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe CreditRating, type: :model do
  it { should validate_presence_of :description }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }
end
