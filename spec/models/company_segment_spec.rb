# == Schema Information
#
# Table name: company_segments
#
#  id           :uuid             not null, primary key
#  commission   :decimal(15, 4)
#  company_rate :decimal(15, 4)   not null
#  credit_limit :decimal(15, 4)   not null
#  currency     :string
#  extra1       :string
#  extra2       :string
#  extra3       :string
#  key          :string           not null
#  max_period   :decimal(15, 4)   not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :uuid             not null
#
# Indexes
#
#  index_company_segments_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
require 'rails_helper'

RSpec.describe CompanySegment, type: :model do
  it { should validate_presence_of :key }
  it { should validate_presence_of :company_rate }
  it { should validate_presence_of :credit_limit }
  it { should validate_presence_of :max_period }
  it { should validate_presence_of :commission }
end
