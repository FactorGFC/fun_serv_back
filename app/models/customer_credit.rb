# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_credits
#
#  id                :uuid             not null, primary key
#  amount_allowed    :decimal(15, 4)
#  attached          :string
#  balance           :decimal(15, 4)   not null
#  capital           :decimal(15, 4)   not null
#  credit_folio      :string
#  currency          :string
#  debt_time         :decimal(15, 4)
#  destination       :string
#  end_date          :date             not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  fixed_payment     :decimal(15, 4)   not null
#  interests         :decimal(15, 4)   not null
#  iva               :decimal(15, 4)   not null
#  iva_percent       :decimal(15, 4)
#  rate              :decimal(, )      not null
#  restructure_term  :integer
#  start_date        :date             not null
#  status            :string           not null
#  time_allowed      :decimal(15, 4)
#  total_debt        :decimal(15, 4)   not null
#  total_payments    :decimal(15, 4)   not null
#  total_requested   :decimal(15, 4)   not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  credit_rating_id  :uuid
#  customer_id       :uuid             not null
#  payment_period_id :uuid
#  term_id           :uuid
#  user_id           :uuid
#
# Indexes
#
#  index_customer_credits_on_credit_rating_id   (credit_rating_id)
#  index_customer_credits_on_customer_id        (customer_id)
#  index_customer_credits_on_payment_period_id  (payment_period_id)
#  index_customer_credits_on_term_id            (term_id)
#  index_customer_credits_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#  fk_rails_...  (user_id => users.id)
#
class CustomerCredit < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CustomerCreditSchema
  belongs_to :customer
  belongs_to :payment_period, optional: true
  belongs_to :term, optional: true
  belongs_to :user, optional: true
  #belongs_to :credit_rating
  
  has_many :sim_customer_payments, dependent: :destroy
  #has_many :current_customer_payments
  has_many :current_payments, -> { current_customer_payments }, class_name: 'SimCustomerPayment'
  has_many :pending_payments, -> { pending_customer_payments }, class_name: 'SimCustomerPayment'
  has_many :credit_analysis

  
  validates :start_date, presence: true
  validates :status, presence: true
  validates :total_requested, presence: true
  validates :capital, presence: true
  validates :interests, presence: true
  validates :iva, presence: true
  validates :total_debt, presence: true
  validates :total_payments, presence: true
  validates :balance, presence: true
  validates :fixed_payment, presence: true
  validates :rate, presence: true
  
  before_create :calculate_balance_credit
  before_create :create_folio

  def calculate_balance_credit
  #  puts 'aqui calcula el balance!!!!!!!!!'
    self[:balance] = self[:total_debt] - self[:total_payments]
   # puts 'balanceeeee' + self[:balance].inspect
   # puts 'total_debt' + self[:total_debt].inspect
  end

  def create_folio
    t = Time.now
    folio = t.to_i
    self[:credit_folio] = "CN#{folio.to_s}"
  end
end
