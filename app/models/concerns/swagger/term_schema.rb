module Swagger::TermSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :TermOutput do
      key :required, [:id, :key, :description, :value, :term_type, :credit_limit]
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
        key :type, :integer
      end
      property :term_type do
        key :type, :string
      end
      property :credit_limit do
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