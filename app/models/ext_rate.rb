# frozen_string_literal: true

# == Schema Information
#
# Table name: ext_rates
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  end_date    :date
#  key         :string           not null
#  max_value   :decimal(15, 4)
#  rate_type   :string           not null
#  start_date  :date             not null
#  value       :decimal(15, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ExtRate < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ExtRateSchema
  validates :description, presence: true
  validates :key, presence: true
  validates :rate_type, presence: true
  validates :start_date, presence: true
  validates :value, presence: true, numericality: true
  validates :key, uniqueness: { scope: :start_date }

  def self.get_ext_rate_value(key)
    @ext_rate = ExtRate.where(key: key)
    unless @ext_rate.empty?
      @ext_rate_value = @ext_rate[0].value
      @ext_rate_value
    end
  end
end
