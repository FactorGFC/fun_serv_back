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

      def self.get_credit_payments(id)
        @query = 
        "select p.pay_number, p.current_debt, p.remaining_debt, p.payment, p.capital, p.interests, p.payment_date, p.status,
        (select email from users where id = (select user_id from customers where id = (select customer_id from customer_credits c where id=p.customer_credit_id))),
        (select name from users where id = (select user_id from customers where id = (select customer_id from customer_credits c where id=p.customer_credit_id)))
        from sim_customer_payments p
        where customer_credit_id = '#{id}'"
        begin
          result = self.connection.exec_query(@query, :skip_logging)
          self.connection.close
        rescue => e
          Debug.exception e, 'exec_q'
          self.connection.close
          result = nil
        end
        return result
      end
end
