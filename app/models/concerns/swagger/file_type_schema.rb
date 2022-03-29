module Swagger::FileTypeSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :FileTypeOutput do
      key :required, [:id, :name, :description]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :name do
        key :type, :string
      end
      property :description do
        key :type, :string
      end
      property :customer_type do
        key :type, :string
      end
      property :funder_type do
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