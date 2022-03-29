module Swagger::CreditRatingSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CreditRatingOutput do
      key :required, [:id, :key, :description, :value]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :key do
        key :type, :string
      end
      property :description do
        key :type, :string
      end
      property :value_type do
        key :type, :number
        key :format, :float
      end
      property :cr_type do
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