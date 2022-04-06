module Swagger::CustomerPersonalReferenceSchema
    extend ActiveSupport::Concern
    include Swagger::Blocks
  
    included do
      swagger_schema :CustomerPersonalReferenceOutput do
        key :required, [:id, :fisrt_name, :last_name, :second_last_name, :customer_id ]
        property :id do
          key :type, :string
          key :format, :uuid
        end
        property :fisrt_name do
          key :type, :string
        end
        property :last_name do
          key :type, :string
        end
        property :second_last_name do
          key :type, :string
        end
        property :address do
          key :type, :string
        end
        property :phone do
          key :type, :string
        end
        property :reference_type do
          key :type, :string
        end
        property :customer_id do
          key :type, :string
          key :format, :uuid
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