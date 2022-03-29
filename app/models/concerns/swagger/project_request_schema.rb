module Swagger::ProjectRequestSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ProjectRequestOutput do
      key :required, [:id, :project_type, :folio, :currency, :total, :request_date, :status, :customer_id, :user_id, :term_id, :payment_period_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :project_type do
        key :type, :string
      end
      property :folio do
        key :type, :string
      end
      property :currency do
        key :type, :string
      end
      property :total do
        key :type, :number
        key :format, :float
      end
      property :request_date do
        key :type, :string
        key :format, :date
      end
      property :status do
        key :type, :string
      end
      property :attached do
        key :type, :string
      end
      property :customer_id do
        key :type, :string
        key :format, :uuid
      end   
      property :user_id do
        key :type, :string
        key :format, :uuid
      end
      property :term_id do
        key :type, :string
        key :format, :uuid
      end
      property :payment_period_id do
        key :type, :string
        key :format, :uuid
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