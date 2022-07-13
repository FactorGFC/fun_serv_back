class Company < ApplicationRecord
end
# == Schema Information
#
# Table name: companies
#
#  id               :uuid             not null, primary key
#  balance          :decimal(15, 4)
#  business_name    :string           not null
#  company_rate     :decimal(, )
#  credit_available :decimal(15, 4)
#  credit_limit     :decimal(15, 4)
#  document         :string
#  sector           :string
#  start_date       :date             not null
#  subsector        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contributor_id   :uuid             not null
#
# Indexes
#
#  index_companies_on_contributor_id  (contributor_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#
class Company < ApplicationRecord
    include Swagger::Blocks
    include Swagger::CompanySchema
    belongs_to :contributor
    has_many :customers
    has_many :people, through: :contributors
    has_many :legal_entities, through: :contributors
    before_save :calculate_balance_company
  
    validates :business_name, presence: true
    validates :start_date, presence: true
    validates :contributor, presence: true, uniqueness: true
  
    def calculate_balance_company
      self[:balance] = self[:credit_limit] - self[:credit_available]
    end
  end
  
