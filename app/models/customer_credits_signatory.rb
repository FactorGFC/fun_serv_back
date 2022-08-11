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
class CustomerCreditsSignatory < ApplicationRecord
  # belongs_to :customer_credit, :class_name => 'CustomerCredit',:foreign_key => 'customer_credit_id', :validate => true
  belongs_to :customer_credit
  # belongs_to :customer_credit
  # belongs_to :user, :class_name => 'User',:foreign_key => 'user_id', :validate => true
  belongs_to :user
  # belongs_to :user

  has_many :users

  validates :signatory_token, presence: true
  validates :signatory_token_expiration, presence: true
  validates :status, presence: true
  # validates :customer_credit_id, presence: true
  # validates :user_id, presence: true
end
