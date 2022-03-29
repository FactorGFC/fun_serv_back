# == Schema Information
#
# Table name: legal_entities
#
#  id             :uuid             not null, primary key
#  business_email :string
#  business_name  :string           not null
#  email          :string
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  fiel           :boolean
#  fiscal_regime  :string           not null
#  main_activity  :string
#  mobile         :string
#  phone          :string
#  rfc            :string           not null
#  rug            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :legal_entity do
    fiscal_regime { "PERSONA MORAL" }
    sequence(:rfc) { |n| "ROAE840610U70#{n}" }
    rug { "123456AAA" }
    business_name { "Google" }
    phone { "999999999999" }
    mobile { "999999999999" }
    email { "email@email.com" }
    business_email { "bemail@email.com" }
    main_activity { "Agropecuaria" }
    fiel { false }
    extra1 { "MyString1" }
    extra2 { "MyString2" }
    extra3 { "MyString3" }
  end
  factory :legal_entity_fija do
    fiscal_regime { "PERSONA MORAL" }
    rfc { "BBBB888888B888" }
    rug { "123456AAA" }
    business_name { "Google" }
    phone { "999999999999" }
    mobile { "999999999999" }
    email { "email@email.com" }
    business_email { "bemail@email.com" }
    main_activity { "Agropecuaria" }
    fiel { false }
    extra1 { "MyString1" }
    extra2 { "MyString2" }
    extra3 { "MyString3" }
  end
  factory :legal_entity_finan do
    fiscal_regime { "PERSONA MORAL" }
    rfc { "FGG120928632" }
    business_name { "FACTOR GFC GLOBAL SA DE CV SOFOM ENR" }
    phone { "999999999999" }
    mobile { "999999999999" }
    email { "erodriguez@gmail.com" }
    business_email { "eloyra@gmail.com" }
    main_activity { "Financiero" }
    fiel { false }
    extra1 { "MyString1" }
    extra2 { "MyString2" }
    extra3 { "MyString3" }
  end
end
