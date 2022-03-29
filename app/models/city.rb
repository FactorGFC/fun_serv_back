# == Schema Information
#
# Table name: cities
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_cities_on_state_id  (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#
class City < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CitySchema
  belongs_to :state
  validates :name, presence: true
end
