module Swagger::ExtRateSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ExtRateOutput do
      key :required, [:id, :key, :description, :start_date, :value, :rate_type]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :key do
        key :type, :string
      end
      property :description do
        key :type, :string
      end
      property :start_date do
        key :type, :string
        key :format, 'date'
      end
      property :end_date do
        key :type, :string
        key :format, 'date'
      end
      property :value do
        key :type, :number
        key :format, :float
      end
      property :rate_type do
        key :type, :string
      end
      property :max_value do
        key :type, :number
        key :format, :float
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