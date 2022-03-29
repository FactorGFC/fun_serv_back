module Swagger::ContributorDocumentSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ContributorDocumentOutput do
      key :required, [:id, :contributor_id, :file_type_document_id, :name, :status]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :contributor_id do
        key :type, :string
        key :format, :uuid
      end
      property :name do
        key :type, :string
      end
      property :status do
        key :type, :string
      end
      property :notes do
        key :type, :string
      end
      property :url do
        key :type, :string
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
