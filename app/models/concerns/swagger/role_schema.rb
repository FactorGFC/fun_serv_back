module Swagger::RoleSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :RoleOutput do
      key :required, [:id, :name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :name do
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