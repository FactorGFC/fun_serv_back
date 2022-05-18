# == Schema Information
#
# Table name: payment_credits
#
#  id                 :uuid             not null, primary key
#  pc_type            :string           not null
#  total              :decimal(15, 4)   not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_credit_id :uuid             not null
#  payment_id         :uuid             not null
#
# Indexes
#
#  index_payment_credits_on_customer_credit_id  (customer_credit_id)
#  index_payment_credits_on_payment_id          (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#  fk_rails_...  (payment_id => payments.id)
#
class PaymentCredit < ApplicationRecord
    belongs_to :payment
    belongs_to :customer_credit
    validates :payment, presence: true
    validates :customer_credit, presence: true, uniqueness: { scope: :pc_type }
    validates :pc_type, presence: true
    validates :total, presence: true

    def self.custom_update_or_create(payment, customer_credit, pc_type, total)
        # Validando que no se creen dos registros para el mismo pago y el mismo credito
        payment_credit = where(payment: payment, customer_credit: customer_credit, pc_type: pc_type, total: total).first_or_create
      end
end
