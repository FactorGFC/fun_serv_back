# == Schema Information
#
# Table name: project_requests
#
#  id                :uuid             not null, primary key
#  attached          :string
#  currency          :string           not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  folio             :string           not null
#  project_type      :string           not null
#  rate              :decimal(15, 4)
#  request_date      :date             not null
#  status            :string           not null
#  total             :decimal(15, 4)   not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  customer_id       :uuid             not null
#  payment_period_id :uuid             not null
#  term_id           :uuid             not null
#  user_id           :uuid             not null
#
# Indexes
#
#  index_project_requests_on_customer_id        (customer_id)
#  index_project_requests_on_payment_period_id  (payment_period_id)
#  index_project_requests_on_term_id            (term_id)
#  index_project_requests_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#  fk_rails_...  (user_id => users.id)
#
class ProjectRequest < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ProjectRequestSchema
  belongs_to :customer
  belongs_to :user
  belongs_to :term
  belongs_to :payment_period
  has_many :projects
  has_many :customer_credits

  validates :currency, presence: true
  validates :project_type, presence: true
  validates :request_date, presence: true
  validates :status, presence: true
  validates :total, presence: true
  before_create :create_folio

  def create_folio
    t = Time.now
    folio = t.to_i
    self[:folio] = "S#{self[:project_type]}#{folio.to_s}"
  end
end
