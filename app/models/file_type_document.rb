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
class FileTypeDocument < ApplicationRecord
  include Swagger::Blocks
  include Swagger::FileTypeDocumentSchema
  belongs_to :document
  belongs_to :file_type
  has_many :contributor_documents

  def self.custom_update_or_create(file_type, document)
    # Validando que no se creen dos registros para el mismo rol y la misma opcion
    file_type_document = where(file_type: file_type, document: document).first_or_create
  end
end
