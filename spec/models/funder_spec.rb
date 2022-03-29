# == Schema Information
#
# Table name: funders
#
#  id             :uuid             not null, primary key
#  attached       :string
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  funder_type    :string           not null
#  name           :string           not null
#  status         :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  contributor_id :uuid             not null
#  file_type_id   :uuid
#  user_id        :uuid             not null
#
# Indexes
#
#  index_funders_on_contributor_id  (contributor_id)
#  index_funders_on_file_type_id    (file_type_id)
#  index_funders_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_id => file_types.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Funder, type: :model do
  it { should validate_presence_of :funder_type }
  it { should validate_presence_of :name }
  it { should validate_presence_of :status }
  it { should belong_to(:contributor) }
  it { should belong_to(:user) }
end
