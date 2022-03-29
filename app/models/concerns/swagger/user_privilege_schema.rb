module Swagger::UserPrivilegeSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :UserPrivilegeOutput do
      key :required, [:id, :user_id, :description, :key, :value]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :user_id do
        key :type, :integer
        key :format, :bigint
      end
      property :description do
        key :type, :string
      end
      property :key do
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
      property :user_id do
        key :type, :integer
        key :format, :bigint
      end
    end
  end
end