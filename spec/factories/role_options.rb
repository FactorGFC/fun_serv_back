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

FactoryBot.define do
  factory :role_option do
    association :role, factory: :role
    association :option, factory: :option

    factory :role_option_sf do
      association :role
      association :option
    end
  end
end
