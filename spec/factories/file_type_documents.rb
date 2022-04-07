# frozen_string_literal: true
# == Schema Information
#
# Table name: file_type_documents
#
#  id           :uuid             not null, primary key
#  extra1       :string
#  extra2       :string
#  extra3       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  document_id  :uuid             not null
#  file_type_id :uuid             not null
#
# Indexes
#
#  index_file_type_documents_on_document_id   (document_id)
#  index_file_type_documents_on_file_type_id  (file_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#  fk_rails_...  (file_type_id => file_types.id)
#
FactoryBot.define do
  factory :file_type_document do
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :document, factory: :document
    association :file_type, factory: :file_type
  end
end
