# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id          :uuid             not null, primary key
#  description :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Role < ApplicationRecord
  include Swagger::Blocks
  include Swagger::RoleSchema
  has_many :users
  has_many :role_options, dependent: :destroy
  has_many :options, through: :role_options
  validates :name, presence: true
  validates :description, presence: true
end
