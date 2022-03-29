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
FactoryBot.define do
  factory :ext_service do
    supplier { "Tu identidad" }
    user { "factorgfc" }
    api_key { "sjfskljkn4353453jlksf" }
    token { "sjskdfjkl4j534534jlkjsdkj4" }
    url { "https://tuidentidad.com/api/Business/ine" }
    rule { "url+user+token+api_key" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
  end
end
