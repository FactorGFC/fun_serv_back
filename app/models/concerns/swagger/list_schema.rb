module Swagger::ListSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ListOutput do
      key :required, [:id, :domain, :key, :value]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :domain do
        key :type, :string
      end
      property :key do
        key :type, :string
      end
      property :value do
        key :type, :string
      end
      property :description do
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