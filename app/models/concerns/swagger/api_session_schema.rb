module Swagger::ApiSessionSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ApiSessionOutput do
      key :required, [:id, :email, :password, :name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :name do
        key :type, :string
      end
      property :email do
        key :type, :string
        key :format, :email
      end
      property :password_digest do
        key :type, :string
        key :format, :password
      end
      property :job do
        key :type, :string
      end
      property :gender do
        key :type, :string
      end
      property :status do
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
      property :reset_password_token do
        key :type, :string
      end
      property :role_id do
        key :type, :integer
        key :format, :bigint
      end
      property :token do
        key :type, :string
      end
    end
  end
end