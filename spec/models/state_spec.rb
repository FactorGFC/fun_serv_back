# frozen_string_literal: true
# == Schema Information
#
# Table name: states
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  state_key  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :uuid             not null
#
# Indexes
#
#  index_states_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
require 'rails_helper'

RSpec.describe State, type: :model do
  it { should validate_presence_of :state_key }
  it { should validate_presence_of :name }
  it { should belong_to(:country) }
end
