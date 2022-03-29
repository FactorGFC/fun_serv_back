# == Schema Information
#
# Table name: countries
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  phonecode  :integer
#  sortname   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Country < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CountrySchema
  has_many :states
  validates :name, presence: true
  validates :sortname, presence: true
end
