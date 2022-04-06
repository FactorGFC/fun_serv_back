# frozen_string_literal: true
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
FactoryBot.define do
  factory :contributor do
    contributor_type { "PERSONA MORAL" }
    bank { "Bancomer" }
    account_number { 123456789 }
    clabe { 1234567891234567 }
    association :person, factory: :person
    association :legal_entity, factory: :legal_entity
    extra1 { "MyString1" }
    extra2 { "MyString1" }
    extra3 { "MyString3" }
    factory :contributor_with_customer do
      contributor_type { "Persona física" }
      bank { "Bancomer" }
      account_number { 123456789 }
      clabe { 1234567891234567 }
      association :person, factory: :person
      #association :legal_entity, factory: :legal_entity
      extra1 { "MyString1" }
      extra2 { "MyString1" }
      extra3 { "MyString3" }
      customers { build_list :customer, 1 }
    end
    factory :contributor_with_company do
      contributor_type { "Persona física" }
      bank { "Bancomer" }
      account_number { 123456789 }
      clabe { 1234567891234567 }
      association :person, factory: :person
      association :legal_entity, factory: :legal_entity
      extra1 { "MyString1" }
      extra2 { "MyString1" }
      extra3 { "MyString3" }
      companies { build_list :company, 1 }
    end
    factory :sequence_contributor do
      contributor_type { "Persona física" }
      bank { "Bancomer" }
      account_number { 123456789 }
      clabe { 1234567891234567 }
      association :person, factory: :sequence_person
      extra1 { "MyString1" }
      extra2 { "MyString1" }
      extra3 { "MyString3" }
    end
    factory :contributor_pf do
      contributor_type { "PERSONA FÍSICA" }
      bank { "Bancomer" }
      account_number { 123456789 }
      clabe { 1234567891234567 }
      association :person#, factory: :person
      extra1 { "MyString1" }
      extra2 { "MyString1" }
      extra3 { "MyString3" }
    end
    factory :contributor_pm do
      contributor_type { "PERSONA MORAL" }
      bank { "Bancomer" }
      account_number { 123456789 }
      clabe { 1234567891234567 }
      association :legal_entity, factory: :legal_entity
      extra1 { "MyString1" }
      extra2 { "MyString1" }
      extra3 { "MyString3" }
    end
    factory :contributor_finan do
      contributor_type { "PERSONA MORAL" }
      bank { "Bancomer" }
      account_number { 123456789 }
      clabe { 1234567891234567 }
      association :legal_entity, factory: :legal_entity
      extra1 { "MyString1" }
      extra2 { "MyString1" }
      extra3 { "MyString3" }
    end
  end
end

