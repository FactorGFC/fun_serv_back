module Swagger::GeneralParameterSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :GeneralParameterOutput do
      key :required, [:id, :description, :key, :value]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :table do
        key :type, :string
      end
      property :id_table do
        key :type, :integer
        key :format, :bigint
      end
      property :key do
        key :type, :string
      end
      property :description do
        key :type, :string
      end
      property :used_values do
        key :type, :string
      end
      property :value do
        key :type, :string
      end
      property :documentation do
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