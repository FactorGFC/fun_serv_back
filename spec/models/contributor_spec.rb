# == Schema Information
#
# Table name: contributors
#
#  id               :uuid             not null, primary key
#  account_number   :bigint
#  bank             :string
#  clabe            :bigint
#  contributor_type :string           not null
#  extra1           :string
#  extra2           :string
#  extra3           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  legal_entity_id  :uuid
#  person_id        :uuid
#
# Indexes
#
#  index_contributors_on_legal_entity_id  (legal_entity_id)
#  index_contributors_on_person_id        (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_entity_id => legal_entities.id)
#  fk_rails_...  (person_id => people.id)
#
require 'rails_helper'

RSpec.describe Contributor, type: :model do
  it { should validate_presence_of :contributor_type }
  it { should belong_to(:person).optional }
  it { should belong_to(:legal_entity).optional }
end
