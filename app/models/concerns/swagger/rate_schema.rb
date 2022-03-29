module Swagger::RateSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :RateOutput do
      key :required, [:id, :key, :description, :value, :term_id, :payment_period_id]
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
      property :value do
        key :type, :number
        key :format, :float
      end
      property :term_id do
        key :type, :string
        key :format, :uuid
      end
      property :payment_period_id do
        key :type, :string
        key :format, :uuid
      end
      property :credit_rating_id do
        key :type, :string
        key :format, :uuid
      end      
      property :extra1 do
        key :type, :string
      end
      property :extra2 do
        key :type, :string
      end
      property :extra3 do
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