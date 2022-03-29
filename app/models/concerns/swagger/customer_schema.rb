module Swagger::CustomerSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CustomerOutput do
      key :required, [:id, :customer_type, :name, :status, :contributor_id, :user_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :customer_type do
        key :type, :string
      end
      property :name do
        key :type, :string
      end
      property :status do
        key :type, :string
      end
      property :attached do
        key :type, :string
      end
      property :contributor_id do
        key :type, :string
        key :format, :uuid
      end
      property :user_id do
        key :type, :string
        key :format, :uuid
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
