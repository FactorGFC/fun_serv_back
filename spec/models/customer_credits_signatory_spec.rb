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
require 'rails_helper'

RSpec.describe CustomerCreditsSignatory, type: :model do
  it { should validate_presence_of :signatory_token }
  it { should validate_presence_of :signatory_token_expiration }
  it { should validate_presence_of :status }
  # it { should validate_presence_of :customer_credit }
  # it { should validate_presence_of :user }
  it { should belong_to(:customer_credit) }
  it { should belong_to(:user) }
end
