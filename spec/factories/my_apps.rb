# frozen_string_literal: true

# == Schema Information
#
# Table name: my_apps
#
#  id                 :uuid             not null, primary key
#  javascript_origins :string
#  secret_key         :string
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  app_id             :string
#  user_id            :uuid             not null
#
# Indexes
#
#  index_my_apps_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :my_app do
    association :user
    title { 'MyString' }
    javascript_origins { 'http://localhost' }
  end
end
