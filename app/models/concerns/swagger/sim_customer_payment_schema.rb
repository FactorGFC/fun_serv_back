module Swagger::SimCustomerPaymentSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :SimCustomerPaymentOutput do
      key :required, [:id, :pay_number, :current_debt, :remaining_debt, :payment, :capital, :interests, :iva, :payment_date, :status, :customer_credit_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :pay_number do
        key :type, :number
        key :format, :integer
      end
      property :current_debt do
        key :type, :number
        key :format, :float
      end
      property :remaining_debt do
        key :type, :number
        key :format, :float
      end
      property :payment do
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
      property :payment_date do
        key :type, :string
        key :format, :date
      end
      property :status do
        key :type, :string
      end
      property :attached do
        key :type, :string
      end
      property :customer_credit_id do
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
      property :insurance do
        key :type, :number
        key :format, :float
      end
      property :commision do
        key :type, :number
        key :format, :float
      end
      property :decimal do
        key :type, :number
        key :format, :float
      end
    end
  end
end