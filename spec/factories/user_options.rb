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

FactoryBot.define do
  factory :user_option do
    association :user, factory: :user
    association :option, factory: :option
  end
end
