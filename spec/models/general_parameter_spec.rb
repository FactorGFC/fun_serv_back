# == Schema Information
#
# Table name: general_parameters
#
#  id            :uuid             not null, primary key
#  description   :string           not null
#  documentation :string
#  id_table      :integer
#  key           :string           not null
#  table         :string
#  used_values   :string
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe GeneralParameter, type: :model do
  it { should validate_presence_of :key }
  it { should validate_presence_of :description }
  it { should validate_presence_of :value }
end
