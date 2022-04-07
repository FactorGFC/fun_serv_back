module Swagger::CompanySchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CompanyOutput do
      key :required, [:id, :contributor_id, :business_name, :start_date, :credit_limit, :credit_available]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :contributor_id do
        key :type, :integer
        key :format, :bigint
      end
      property :start_date do
        key :type, :string
        key :format, :date
      end
      property :credit_limit do
        key :type, :number
        key :format, :float
      end
      property :credit_available do
        key :type, :number
        key :format, :float
      end
      property :balance do
        key :type, :number
        key :format, :float
      end
      property :document do
        key :type, :string
      end
      property :sector do
        key :type, :string
      end
      property :subsector do
        key :type, :string
      end
      property :company_rate do
        key :type, :string
        key :format, :date
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