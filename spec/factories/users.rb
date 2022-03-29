# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :uuid             not null, primary key
#  email                :string           default(""), not null
#  gender               :string
#  job                  :string
#  name                 :string           default(""), not null
#  password_digest      :string           default(""), not null
#  reset_password_token :string
#  status               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  role_id              :uuid
#
# Indexes
#
#  index_users_on_role_id  (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#

require 'faker'
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { '123456789' }
    name { Faker::Name.name }
    factory :dummy_user do
      email { Faker::Internet.email }
      password { '123456789' }
      name { Faker::Name.name }
    end
    factory :user_with_privileges do
      email { Faker::Internet.email }
      password { '123456789' }
      name { Faker::Name.name }
      user_privileges { build_list :user_privilege, 2 }
    end
    factory :sequence_user do
      sequence(:email) { |n| "person#{n}@example.com" }
      password { '123456789' }
      name { Faker::Name.name }
    end
    factory :user_with_role do
      sequence(:email) { |n| "person2#{n}@example.com" }
      password { '123456789' }
      name { Faker::Name.name }
      association :role, factory: :role
    end
  end
end
