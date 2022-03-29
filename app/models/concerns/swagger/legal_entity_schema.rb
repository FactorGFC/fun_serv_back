module Swagger::LegalEntitySchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :LegalEntityOutput do
      key :required, [:id, :fiscal_regime, :rfc, :business_name]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :fiscal_regime do
        key :type, :string
      end
      property :rfc do
        key :type, :string
      end
      property :rug do
        key :type, :string
      end
      property :business_name do
        key :type, :string
      end
      property :phone do
        key :type, :string
      end
      property :mobile do
        key :type, :string
      end
      property :email do
        key :type, :string
      end
      property :business_email do
        key :type, :string
      end
      property :main_activity do
        key :type, :string
      end
      property :fiel do
        key :type, :string
      end
      property :extra1 do
        key :type, :string
      end
      property :extra2 do
        key :type, :string
      end
      property :extra3 do
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