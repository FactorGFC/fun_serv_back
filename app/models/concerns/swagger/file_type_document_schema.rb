module Swagger::FileTypeDocumentSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :FileTypeDocumentOutput do
      key :required, [:id, :file_type_id, :document_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :file_type_id do
        key :type, :string
        key :format, :uuid
      end
      property :document_id do
        key :type, :string
        key :format, :uuid
      end      
      property :created_at do
        key :type, :string
        key :format, 'date-time'
      end
      property :updated_at do
        key :type, :string
        key :format, 'date-time'
      end
    end
  end
end