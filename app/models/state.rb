# == Schema Information
#
# Table name: states
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  state_key  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :uuid             not null
#
# Indexes
#
#  index_states_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
class State < ApplicationRecord
  include Swagger::Blocks
  include Swagger::StateSchema
  belongs_to :country
  has_many :cities
  has_many :municipalities
  validates :name, presence: true
  validates :state_key, presence: true
end
