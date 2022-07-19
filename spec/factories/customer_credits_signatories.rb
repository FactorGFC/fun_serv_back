# == Schema Information
#
# Table name: customer_credits_signatories
#
#  id                         :uuid             not null, primary key
#  notes                      :string
#  signatory_token            :string
#  signatory_token_expiration :datetime
#  status                     :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  customer_credit_id         :uuid             not null
#  user_id                    :uuid             not null
#
# Indexes
#
#  index_customer_credits_signatories_on_customer_credit_id  (customer_credit_id)
#  index_customer_credits_signatories_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :customer_credits_signatory do
    # id { "MyString" }
    signatory_token { "12345abc" }
    signatory_token_expiration { "2022-07-11 09:19:23" }
    status { "AC" }
    created_at { "2022-07-11 09:19:23" }
    updated_at { "2022-07-11 09:19:23" }
    notes { "TESTS" }
    customer_credit_id { nil }
    user_id { nil }
    association :customer_credit, factory: :customer_credit
    association :user, factory: :user

  end
end
