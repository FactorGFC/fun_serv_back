# == Schema Information
#
# Table name: sim_customer_payments
#
#  id                 :uuid             not null, primary key
#  attached           :string
#  capital            :decimal(15, 4)   not null
#  current_debt       :decimal(15, 4)   not null
#  extra1             :string
#  extra2             :string
#  extra3             :string
#  interests          :decimal(15, 4)   not null
#  iva                :decimal(15, 4)   not null
#  pay_number         :integer          not null
#  payment            :decimal(15, 4)   not null
#  payment_date       :date
#  remaining_debt     :decimal(15, 4)   not null
#  status             :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_credit_id :uuid             not null
#
# Indexes
#
#  index_sim_customer_payments_on_customer_credit_id  (customer_credit_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_credit_id => customer_credits.id)
#
class SimCustomerPayment < ApplicationRecord
  include Swagger::Blocks
  include Swagger::SimCustomerPaymentSchema
  belongs_to :customer_credit
  scope :current_customer_payments, -> { where('status != ?', 'CA').order('pay_number') }
  scope :pending_customer_payments, -> { where('status = ?', 'PE').order('pay_number') }

  validates :capital, presence: true
  validates :interests, presence: true
  validates :iva, presence: true
  validates :pay_number, presence: true
  validates :payment, presence: true
  validates :payment_date, presence: true
  validates :current_debt, presence: true
  validates :remaining_debt, presence: true
  validates :status, presence: true
end
