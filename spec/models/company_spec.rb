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
require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should validate_presence_of :business_name }
  it { should validate_presence_of :company_rate }
  it { should validate_presence_of :contributor }
end
