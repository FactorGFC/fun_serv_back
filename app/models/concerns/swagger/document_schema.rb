module Swagger::DocumentSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :DocumentOutput do
      key :required, [:id, :document_type, :name, :description]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :ext_service_id do
        key :type, :string
        key :format, :uuid
      end
      property :document_type do
        key :type, :string
      end
      property :name do
        key :type, :string
      end
      property :description do
        key :type, :string
      end
      property :validation do
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