# == Schema Information
#
# Table name: payments
#
#  id                  :uuid             not null, primary key
#  amount              :decimal(15, 4)   not null
#  currency            :string           not null
#  email_cfdi          :string           not null
#  notes               :string
#  payment_date        :date             not null
#  payment_number      :string           not null
#  payment_type        :string           not null
#  voucher             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  contributor_from_id :uuid             not null
#  contributor_to_id   :uuid             not null
#
# Indexes
#
#  index_payments_on_contributor_from_id  (contributor_from_id)
#  index_payments_on_contributor_to_id    (contributor_to_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_from_id => contributors.id)
#  fk_rails_...  (contributor_to_id => contributors.id)
#
require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { should validate_presence_of :amount }
  it { should validate_presence_of :currency }
  it { should validate_presence_of :email_cfdi }
  it { should_not allow_value('eloy@gmail').for(:email_cfdi) }
  it { should allow_value('eloy@gmail.com').for(:email_cfdi) }
  it { should validate_presence_of :payment_date}
  it { should validate_presence_of :payment_number }
  it { should validate_presence_of :payment_type }
  it { should validate_presence_of :contributor_from_id }
  it { should validate_presence_of :contributor_to_id}
end
