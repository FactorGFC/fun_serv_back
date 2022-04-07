# frozen_string_literal: true

# == Schema Information
#
# Table name: user_privileges
#
#  id            :uuid             not null, primary key
#  description   :string           not null
#  documentation :string
#  key           :string           not null
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_user_privileges_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserPrivilege < ApplicationRecord
  include Swagger::Blocks
  include Swagger::UserPrivilegeSchema
  belongs_to :user
  validates :description, presence: true
  validates :key, presence: true
  validates :value, presence: true
  validates :user, presence: true
end
