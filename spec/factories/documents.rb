# frozen_string_literal: true
# == Schema Information
#
# Table name: documents
#
#  id             :uuid             not null, primary key
#  description    :string           not null
#  document_type  :string           not null
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  name           :string           not null
#  validation     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ext_service_id :uuid
#
# Indexes
#
#  index_documents_on_ext_service_id  (ext_service_id)
#
# Foreign Keys
#
#  fk_rails_...  (ext_service_id => ext_services.id)
#
FactoryBot.define do
  factory :document do
    document_type { "Identificación" }
    name { "Credencial de elector" }
    description { "Credencial de elector del Instituto Nacional Electoral" }
    validation { "Rostro por OCR" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :ext_service, factory: :ext_service
  end
end
