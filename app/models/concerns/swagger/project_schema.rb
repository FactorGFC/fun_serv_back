module Swagger::ProjectSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ProjectOutput do
      key :required, [:id, :project_type, :folio, :client_rate, :funder_rate, :ext_rate, :total, :interests, :financial_cost, :currency, :entry_date, :status, :customer_id, :user_id, :project_request_id, :term_id, :payment_period_id, :credit_rating_id]
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
      property :client_rate do
        key :type, :number
        key :format, :float
      end
      property :funder_rate do
        key :type, :number
        key :format, :float
      end
      property :ext_rate do
        key :type, :number
        key :format, :float
      end
      property :total do
        key :type, :number
        key :format, :float
      end
      property :interests do
        key :type, :number
        key :format, :float
      end
      property :financial_cost do
        key :type, :number
        key :format, :float
      end
      property :currency do
        key :type, :string
      end
      property :entry_date do
        key :type, :string
        key :format, :date
      end
      property :used_date do
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
      property :project_request_id do
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
      property :credit_rating_id do
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