# == Schema Information
#
# Table name: people
#
#  id               :uuid             not null, primary key
#  birth_country    :string
#  birthdate        :date             not null
#  birthplace       :string
#  curp             :string
#  email            :string
#  extra1           :string
#  extra2           :string
#  extra3           :string
#  fiel             :boolean
#  first_name       :string           not null
#  fiscal_regime    :string           not null
#  gender           :string
#  id_type          :string
#  identification   :bigint           not null
#  imss             :bigint
#  last_name        :string           not null
#  martial_status   :string
#  mobile           :string
#  nationality      :string
#  phone            :string
#  rfc              :string           not null
#  second_last_name :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :person do
    fiscal_regime { "PERSONA FÍSICA" }
    sequence(:rfc) { |n| "ROAE840610U7#{n}" }
    curp { "100790ABAB1234" }
    imss { 123456789 }
    first_name { "Pedro" }
    last_name { "Perez" }
    second_last_name { "Perez" }
    gender { "Masculino" }
    nationality { "Mexicana" }
    birth_country { "Chihuahua" }
    birthplace { "La Junta" }
    birthdate { 21.years.ago }
    martial_status { "Soltero" }
    id_type { "INE" }
    identification { 123456789 }
    phone { "999999999999" }
    mobile { "888888888888" }
    email { "email@mail.com" }
    fiel { true }
    extra1 { "MyString1" }
    extra2 { "MyString2" }
    extra3 { "MyString3" }
    factory :sequence_person do
      fiscal_regime { "PERSONA FÍSICA" }
      sequence(:rfc) { |n| "#{n}AA100790XYZ" }
      curp { "100790ABAB1234" }
      imss { 123456789 }
      first_name { "Pedro" }
      last_name { "Perez" }
      second_last_name { "Perez" }
      gender { "Masculino" }
      nationality { "Mexicana" }
      birth_country { "Chihuahua" }
      birthplace { "La Junta" }
      birthdate { 21.years.ago }
      martial_status { "Soltero" }
      id_type { "INE" }
      identification { 123456789 }
      phone { "999999999999" }
      mobile { "888888888888" }
      email { "email@mail.com" }
      fiel { false }
      extra1 { "MyString1" }
      extra2 { "MyString2" }
      extra3 { "MyString3" }
    end
  end
  
end
