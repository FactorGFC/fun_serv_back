module Swagger::PersonSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :PersonOutput do
      key :required, [:id, :fiscal_regime, :rfc, :first_name, 
                      :last_name, :second_last_name, :birthdate, :identification]
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
      property :curp do
        key :type, :string
      end
      property :imss do
        key :type, :integer
      end
      property :first_name do
        key :type, :string
      end
      property :last_name do
        key :type, :string
      end
      property :second_last_name do
        key :type, :string
      end
      property :gender do
        key :type, :string
      end
      property :nationality do
        key :type, :string
      end
      property :birth_country do
        key :type, :string
      end
      property :birthplace do
        key :type, :string
      end
      property :birthdate do
        key :type, :string
        key :format, 'date'
      end
      property :martial_status do
        key :type, :string
      end
      property :id_type do
        key :type, :string
      end
      property :identification do
        key :type, :integer
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