# frozen_string_literal: true
# == Schema Information
#
# Table name: rates
#
#  id                :uuid             not null, primary key
#  description       :string           not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  key               :string           not null
#  value             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  credit_rating_id  :uuid
#  payment_period_id :uuid
#  term_id           :uuid
#
# Indexes
#
#  index_rates_on_credit_rating_id   (credit_rating_id)
#  index_rates_on_payment_period_id  (payment_period_id)
#  index_rates_on_term_id            (term_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#
require 'rails_helper'

RSpec.describe Rate, type: :model do
  it { should validate_presence_of :key }
  it { should validate_presence_of :description }
  it { should validate_presence_of :value }
  it { should belong_to(:term) }
  it { should belong_to(:payment_period) }
  it { should belong_to(:credit_rating).optional }
end
