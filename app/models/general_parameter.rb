# == Schema Information
#
# Table name: general_parameters
#
#  id            :uuid             not null, primary key
#  description   :string           not null
#  documentation :string
#  id_table      :integer
#  key           :string           not null
#  table         :string
#  used_values   :string
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class GeneralParameter < ApplicationRecord
  include Swagger::Blocks
  include Swagger::GeneralParameterSchema
  validates :description, presence: true
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.get_general_parameter_value(key)
    @general_parameter = GeneralParameter.where(key: key)
    unless @general_parameter.empty?
      @general_parameter_value = @general_parameter[0].value
      @general_parameter_value
    end
  end
end
