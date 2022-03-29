module Swagger::UserOptionSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :UserOptionOutput do
      key :required, [:id, :user_id, :option_id]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :user_id do
        key :type, :integer
        key :format, :bigint
      end
      property :option_id do
        key :type, :integer
        key :format, :bigint
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