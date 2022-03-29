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

class Option < ApplicationRecord
  include Swagger::Blocks
  include Swagger::OptionSchema
  include Swagger::ReportSchema
  has_many :role_options, dependent: :destroy
  has_many :roles, through: :role_options
  has_many :user_options, dependent: :destroy
  has_many :users, through: :user_options
  validates :name, presence: true
  validates :description, presence: true

  def self.options_by_not_user(user_id)
    options = Option.find_by_sql ["SELECT options.id, options.name
                                   FROM options
                                   FULL OUTER JOIN user_options on options.id = user_options.option_id
                                   WHERE user_options.user_id <> :user_id or user_options.user_id is null or user_options.option_id is null", { user_id: user_id }]
    options
  end

  def self.options_by_not_role(role_id)
    options = Option.find_by_sql ["SELECT options.id, options.name
                                   FROM options
                                   FULL OUTER JOIN role_options on options.id = role_options.option_id
                                   WHERE role_options.role_id <> :role_id or role_options.role_id is null or role_options.option_id is null", { role_id: role_id }]
    options
  end
end
