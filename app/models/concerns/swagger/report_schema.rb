module Swagger::ReportSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ReportOutput do
      key :required, [:id, :name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :name do
        key :type, :string
      end
    end
  end
end
