module Swagger::CountrySchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CountryOutput do
      key :required, [:id, :sortname, :name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :sortname do
        key :type, :string
      end
      property :name do
        key :type, :string
      end
      property :phonecode do
        key :type, :integer
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