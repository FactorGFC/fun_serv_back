# == Schema Information
#
# Table name: user_privileges
#
#  id            :uuid             not null, primary key
#  description   :string           not null
#  documentation :string
#  key           :string           not null
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_user_privileges_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe UserPrivilege, type: :model do
  it { should validate_presence_of :description }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }
  it { should validate_presence_of :user }
end
