# frozen_string_literal: true
# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  description :string
#  domain      :string           not null
#  key         :string           not null
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lists_on_domain_and_key  (domain,key) UNIQUE
#

require 'rails_helper'

RSpec.describe List, type: :model do
  it { should validate_presence_of :domain }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }
end
