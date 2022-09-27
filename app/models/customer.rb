# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                  :uuid             not null, primary key
#  assist_bonus        :decimal(15, 4)
#  attached            :string
#  child_support       :decimal(15, 4)
#  christmas_bonus     :decimal(15, 4)
#  credit_cp           :decimal(15, 4)
#  credit_lp           :decimal(15, 4)
#  customer_type       :string           not null
#  extra1              :string
#  extra2              :string
#  extra3              :string
#  extra_expenses      :decimal(15, 4)
#  family_expenses     :decimal(15, 4)
#  food_vouchers       :decimal(15, 4)
#  house_rent          :decimal(15, 4)
#  immediate_superior  :string
#  imms                :decimal(15, 4)
#  infonavit           :decimal(15, 4)
#  insurance_discount  :decimal(15, 4)
#  job                 :string
#  name                :string           not null
#  net_expenses        :decimal(15, 4)
#  ontime_bonus        :decimal(15, 4)
#  other_income        :decimal(15, 4)
#  salary              :decimal(15, 4)   not null
#  salary_period       :string           not null
#  savings_bank        :decimal(15, 4)
#  savings_found       :decimal(15, 4)
#  savings_found_loand :decimal(15, 4)
#  seniority           :decimal(15, 4)
#  status              :string           not null
#  taxes               :decimal(15, 4)
#  total_income        :decimal(15, 4)
#  total_savings_found :decimal(15, 4)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :uuid
#  contributor_id      :uuid             not null
#  file_type_id        :uuid
#  user_id             :uuid
#
# Indexes
#
#  index_customers_on_company_id      (company_id)
#  index_customers_on_contributor_id  (contributor_id)
#  index_customers_on_file_type_id    (file_type_id)
#  index_customers_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_id => file_types.id)
#  fk_rails_...  (user_id => users.id)
#
class Customer < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CustomerSchema  
  belongs_to :contributor
  belongs_to :user, optional: true
  belongs_to :file_type, optional: true
  belongs_to :company
  has_many :customer_credits
  has_many :customer_personal_references
  has_many :people, through: :contributors
  has_many :legal_entities, through: :contributors
  has_many :credit_bureaus

  validates :customer_type, presence: true
  validates :name, presence: true
  validates :status, presence: true
  validates :salary, presence: true
  validates :salary_period, presence: true

  def self.get_customer_company_address(id)
    @query = "SELECT  coa.suburb colonia,coa.street calle, coa.external_number numero_exterior,
    coa.postal_code codigo_postal, mun.name municipio, sta.name estado
    FROM customer_credits cuc
      JOIN customers cus ON (cus.id = cuc.customer_id)
      JOIN contributors con ON (cus.contributor_id = con.id)
      JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
      JOIN states sta ON (sta.id = coa.state_id)
      JOIN municipalities mun ON (mun.id = coa.municipality_id)
              WHERE cuc.id = ':customer_credit_id';"
    @query = @query.gsub ':customer_credit_id', id.to_s
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
