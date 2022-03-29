# == Schema Information
#
# Table name: customers
#
#  id             :uuid             not null, primary key
#  attached       :string
#  customer_type  :string           not null
#  extra1         :string
#  extra2         :string
#  extra3         :string
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
#  index_customers_on_contributor_id  (contributor_id)
#  index_customers_on_file_type_id    (file_type_id)
#  index_customers_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_id => file_types.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :customer do
    name { "Carlos Acosta" }
    customer_type { "CF" }
    status { "AC" }
    attached { "https://localhost/contrato.doc" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :contributor, factory: :contributor
    association :user, factory: :user
    association :file_type, factory: :file_type
  end
end
