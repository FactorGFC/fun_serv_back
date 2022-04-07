# frozen_string_literal: true

# == Schema Information
#
# Table name: user_options
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  option_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_user_options_on_option_id  (option_id)
#  index_user_options_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (option_id => options.id)
#  fk_rails_...  (user_id => users.id)
#
class UserOption < ApplicationRecord
  include Swagger::Blocks
  include Swagger::UserOptionSchema
  belongs_to :user
  belongs_to :option
  validates :user, presence: true
  validates :option, presence: true

  def self.custom_update_or_create(user, option)
    # Validando que no se creen dos registros para el mismo usuario y la misma opcion
    user_option = where(user: user, option: option).first_or_create
  end
end
