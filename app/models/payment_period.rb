# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_periods
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  extra1      :string
#  extra2      :string
#  extra3      :string
#  key         :string           not null
#  pp_type     :string
#  value       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PaymentPeriod < ApplicationRecord
  include Swagger::Blocks
  include Swagger::PaymentPeriodSchema
  has_many :rates
  has_many :customer_credits

  validates :description, presence: true
  validates :key, presence: true
  validates :value, presence: true
end
