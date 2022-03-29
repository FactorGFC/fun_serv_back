# == Schema Information
#
# Table name: terms
#
#  id           :uuid             not null, primary key
#  credit_limit :decimal(15, 4)   not null
#  description  :string           not null
#  extra1       :string
#  extra2       :string
#  extra3       :string
#  key          :string           not null
#  term_type    :string           not null
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe Term, type: :model do
  it { should validate_presence_of :credit_limit }
  it { should validate_presence_of :description }
  it { should validate_presence_of :key }
  it { should validate_presence_of :term_type }
  it { should validate_presence_of :value }
end
