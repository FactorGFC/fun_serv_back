# frozen_string_literal: true

# == Schema Information
#
# Table name: credit_ratings
#
#  id          :uuid             not null, primary key
#  cr_type     :string
#  description :string           not null
#  extra1      :string
#  extra2      :string
#  extra3      :string
#  key         :string           not null
#  value       :decimal(15, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class CreditRating < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CreditRatingSchema
  has_many :rates
  has_many :customer_credits

  validates :description, presence: true
  validates :key, presence: true
  validates :value, presence: true
end
