module Swagger::ExtServiceSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ExtServiceOutput do
      key :required, [:id, :supplier, :user, :url]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :supplier do
        key :type, :string
      end
      property :user do
        key :type, :string
      end
      property :api_key do
        key :type, :string
      end
      property :token do
        key :type, :string
      end
      property :url do
        key :type, :string
      end
      property :rule do
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