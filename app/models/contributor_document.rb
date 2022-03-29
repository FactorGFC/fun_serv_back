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
class ContributorDocument < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ContributorDocumentSchema
  belongs_to :contributor
  belongs_to :file_type_document

  validates :name, presence: true
  validates :status, presence: true
  def self.custom_update_or_create(contributor, file_type_document, name, status)
    # Validando que no se creen dos registros para el mismo contribuyente y mismo expediente
    contributor_document = where(contributor: contributor, file_type_document: file_type_document, name: name, status: status).first_or_create
  end
end
