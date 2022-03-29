# == Schema Information
#
# Table name: countries
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  phonecode  :integer
#  sortname   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :country do
    sortname { 'MEX' }
    name { 'México' }
    phonecode { 52 }
    factory :country_with_states do
      sortname { 'MEX' }
      name { 'México' }
      phonecode { 52 }
      states { build_list :state, 2 }
    end
  end
end
