# == Schema Information
#
# Table name: ext_rates
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  end_date    :date
#  key         :string           not null
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
end
