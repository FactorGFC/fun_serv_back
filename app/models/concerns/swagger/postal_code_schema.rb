module Swagger::PostalCodeSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :PostalCodeOutput do
      key :required, [:id, :pc, :municipality, :state, :suburb]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :pc do
        key :type, :integer
      end
      property :municipality do
        key :type, :string
      end
      property :state do
        key :type, :string
      end
      property :suburb do
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