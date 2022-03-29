# == Schema Information
#
# Table name: contributor_documents
#
#  id                    :uuid             not null, primary key
#  extra1                :string
#  extra2                :string
#  extra3                :string
#  name                  :string           not null
#  notes                 :string
#  status                :string           not null
#  url                   :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contributor_id        :uuid             not null
#  file_type_document_id :uuid             not null
#
# Indexes
#
#  index_contributor_documents_on_contributor_id         (contributor_id)
#  index_contributor_documents_on_file_type_document_id  (file_type_document_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_document_id => file_type_documents.id)
#
FactoryBot.define do
  factory :contributor_document do
    name { "Credencial de elector" }
    status { "PE" }
    notes { "Pendiente de validar" }
    url { "https://firebase/ine/23324324jlkjl" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :contributor, factory: :contributor
    association :file_type_document, factory: :file_type_document
  end
end
