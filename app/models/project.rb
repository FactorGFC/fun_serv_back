# == Schema Information
#
# Table name: projects
#
#  id                 :uuid             not null, primary key
#  attached           :string
#  client_rate        :decimal(15, 4)   not null
#  currency           :string           not null
#  entry_date         :date             not null
#  ext_rate           :decimal(15, 4)   not null
#  extra1             :string
#  extra2             :string
#  extra3             :string
#  financial_cost     :decimal(15, 4)   not null
#  folio              :string           not null
#  funder_rate        :decimal(15, 4)   not null
#  interests          :decimal(15, 4)   not null
#  project_type       :string           not null
#  status             :string           not null
#  total              :decimal(15, 4)   not null
#  used_date          :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  credit_rating_id   :uuid             not null
#  customer_id        :uuid             not null
#  payment_period_id  :uuid             not null
#  project_request_id :uuid             not null
#  term_id            :uuid             not null
#  user_id            :uuid             not null
#
# Indexes
#
#  index_projects_on_credit_rating_id    (credit_rating_id)
#  index_projects_on_customer_id         (customer_id)
#  index_projects_on_payment_period_id   (payment_period_id)
#  index_projects_on_project_request_id  (project_request_id)
#  index_projects_on_term_id             (term_id)
#  index_projects_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (project_request_id => project_requests.id)
#  fk_rails_...  (term_id => terms.id)
#  fk_rails_...  (user_id => users.id)
#
class Project < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ProjectSchema
  
  belongs_to :customer
  belongs_to :user
  belongs_to :project_request
  belongs_to :term
  belongs_to :payment_period
  belongs_to :credit_rating
  has_many :customer_credits
  has_many :funding_requests

  validates :client_rate, presence: true
  validates :currency, presence: true
  validates :entry_date, presence: true
  validates :ext_rate, presence: true
  validates :financial_cost, presence: true
  validates :folio, presence: true
  validates :funder_rate, presence: true
  validates :interests, presence: true
  validates :project_type, presence: true
  validates :status, presence: true
  validates :total, presence: true
  before_create :create_folio

  def create_folio
    t = Time.now
    folio = t.to_i
    self[:folio] = "#{self[:project_type]}#{folio.to_s}"
  end
end
