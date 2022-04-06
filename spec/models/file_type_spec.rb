# frozen_string_literal: true
# == Schema Information
#
# Table name: file_types
#
#  id            :uuid             not null, primary key
#  customer_type :string
#  description   :string           not null
#  extra1        :string
#  extra2        :string
#  extra3        :string
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe FileType, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
end
