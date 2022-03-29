# frozen_string_literal: true

# == Schema Information
#
# Table name: role_options
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  option_id  :uuid             not null
#  role_id    :uuid             not null
#
# Indexes
#
#  index_role_options_on_option_id  (option_id)
#  index_role_options_on_role_id    (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (option_id => options.id)
#  fk_rails_...  (role_id => roles.id)
#

class RoleOption < ApplicationRecord
  include Swagger::Blocks
  include Swagger::RoleOptionSchema
  belongs_to :role
  belongs_to :option

  validates :role, presence: true
  validates :option, presence: true

  def self.custom_update_or_create(role, option)
    # Validando que no se creen dos registros para el mismo rol y la misma opcion
    role_option = where(role: role, option: option).first_or_create
  end
end
