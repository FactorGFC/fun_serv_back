module Swagger::CustomerCreditSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CustomerCreditOutput do
      key :required, [:id, :total_requested, :capital, :interests, :iva, :fixed_payment, :total_debt, :total_payments, :balance, :status, :start_date, :end_date, :customer_id, :project_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :total_requested do
        key :type, :number
        key :format, :float
      end
      property :capital do
        key :type, :number
        key :format, :float
      end
      property :interests do
        key :type, :number
        key :format, :float
      end
      property :iva do
        key :type, :number
        key :format, :float
      end
      property :fixed_payment do
        key :type, :number
        key :format, :float
      end
      property :total_debt do
        key :type, :number
        key :format, :float
      end
      property :total_payments do
        key :type, :number
        key :format, :float
      end
      property :balance do
        key :type, :number
        key :format, :float
      end
      property :status do
        key :type, :string
      end
      property :start_date do
        key :type, :string
        key :format, :date
      end
      property :end_date do
        key :type, :string
        key :format, :date
      end
      property :attached do
        key :type, :string
      end
      property :customer_id do
        key :type, :string
        key :format, :uuid
      end        
      property :project_id do
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