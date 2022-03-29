# frozen_string_literal: true

# == Schema Information
#
# Table name: tokens
#
#  id         :uuid             not null, primary key
#  expires_at :datetime
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  my_app_id  :uuid
#  user_id    :uuid             not null
#
# Indexes
#
#  index_tokens_on_my_app_id  (my_app_id)
#  index_tokens_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (my_app_id => my_apps.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :token do
    expires_at { '2030-12-31 10:01:18' }
    association :user
    association :my_app
  end
end
