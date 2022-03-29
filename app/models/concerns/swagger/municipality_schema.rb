module Swagger::MunicipalitySchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :MunicipalityOutput do
      key :required, [:id, :state_id, :municipality_key, :name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :state_id do
        key :type, :integer
        key :format, :bigint
      end
      property :municipality_key do
        key :type, :string
      end
      property :name do
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
