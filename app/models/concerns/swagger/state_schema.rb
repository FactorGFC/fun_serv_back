module Swagger::StateSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :StateOutput do
      key :required, [:id, :country_id, :state_key, :name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :country_id do
        key :type, :integer
        key :format, :bigint
      end
      property :state_key do
        key :type, :string
      end
      property :name do
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
