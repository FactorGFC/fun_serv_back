# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  description :string
#  domain      :string           not null
#  key         :string           not null
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lists_on_domain_and_key  (domain,key) UNIQUE
#

class List < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ListSchema
  validates :domain, presence: true
  validates :key, presence: true
  validates :value, presence: true
  validates :domain, uniqueness: { scope: :key }
end
