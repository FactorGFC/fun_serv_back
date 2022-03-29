# == Schema Information
#
# Table name: customer_credits
#
#  id                 :uuid             not null, primary key
#  attached           :string
#  balance            :decimal(15, 4)   not null
#  capital            :decimal(15, 4)   not null
#  end_date           :date             not null
#  extra1             :string
#  extra2             :string
#  extra3             :string
#  fixed_payment      :decimal(15, 4)   not null
#  interests          :decimal(15, 4)   not null
#  iva                :decimal(15, 4)   not null
#  restructure_term   :integer
#  start_date         :date             not null
#  status             :string           not null
#  total_debt         :decimal(15, 4)   not null
#  total_payments     :decimal(15, 4)   not null
#  total_requested    :decimal(15, 4)   not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_id        :uuid             not null
#  project_id         :uuid
#  project_request_id :uuid
#
# Indexes
#
#  index_customer_credits_on_customer_id         (customer_id)
#  index_customer_credits_on_project_id          (project_id)
#  index_customer_credits_on_project_request_id  (project_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (project_request_id => project_requests.id)
#
class CustomerCredit < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CustomerCreditSchema
  belongs_to :customer
  belongs_to :project, optional: true
  belongs_to :project_request, optional: true
  has_many :sim_customer_payments, dependent: :destroy
  #has_many :current_customer_payments
  has_many :current_payments, -> { current_customer_payments }, class_name: 'SimCustomerPayment'
  has_many :pending_payments, -> { pending_customer_payments }, class_name: 'SimCustomerPayment'
  

  validates :start_date, presence: true
  validates :status, presence: true
  validates :total_requested, presence: true
  before_save :calculate_balance_credit

  def calculate_balance_credit
    self[:balance] = self[:total_debt] - self[:total_payments]
  end
end