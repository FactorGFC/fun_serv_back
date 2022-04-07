# frozen_string_literal: true

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
class Term < ApplicationRecord
  include Swagger::Blocks
  include Swagger::TermSchema
  has_many :rates
  has_many :customer_credits

  validates :credit_limit, presence: true
  validates :description, presence: true
  validates :key, presence: true
  validates :term_type, presence: true
  validates :value, presence: true

end
