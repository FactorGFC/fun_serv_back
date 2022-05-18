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
class Payment < ApplicationRecord
    #include Swagger::Blocks
    #include Swagger::PaymentSchema
    belongs_to :contributor_from, class_name: "Contributor"
    belongs_to :contributor_to, class_name: "Contributor"
    has_many :payment_credits, dependent: :destroy
    validates :amount, presence: true
    validates :currency, presence: true
    validates :email_cfdi, presence: true, email: true
    validates :payment_date, presence: true
    validates :payment_number, presence: true
    validates :payment_type, presence: true
    validates :contributor_from_id, presence: true
    validates :contributor_to_id, presence: true
 
end
