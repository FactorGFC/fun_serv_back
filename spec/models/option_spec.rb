# frozen_string_literal: true

# == Schema Information
#
# Table name: options
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  group       :string
#  name        :string           not null
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Option, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
end
