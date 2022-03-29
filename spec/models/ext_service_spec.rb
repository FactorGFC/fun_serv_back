# == Schema Information
#
# Table name: ext_services
#
#  id         :uuid             not null, primary key
#  api_key    :string
#  extra1     :string
#  extra2     :string
#  extra3     :string
#  rule       :string
#  supplier   :string           not null
#  token      :string
#  url        :string           not null
#  user       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe ExtService, type: :model do
  it { should validate_presence_of :supplier }
  it { should validate_presence_of :user }
  it { should validate_presence_of :url }
end
