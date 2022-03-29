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

FactoryBot.define do
  factory :user_privilege do
    association :user
    description { 'Cambiar password de usuarios' }
    key { 'PASS_USR_UPDATE' }
    value { 'SI' }
    documentation { 'Con este privilegio los usuarios pueden cambiar el password de otros usuarios' }
  end
end
