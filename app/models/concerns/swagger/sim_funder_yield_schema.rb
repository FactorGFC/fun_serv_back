module Swagger::SimFunderYieldSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :SimFunderYieldOutput do
      key :required, [:id, :yield_number, :remaining_capital, :capital, :gross_yield, :isr, :net_yield, :total, :payment_date, :status, :investment_id, :funder_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :yield_number do
        key :type, :number
        key :format, :integer
      end
      property :remaining_capital do
        key :type, :number
        key :format, :float
      end
      property :capital do
        key :type, :number
        key :format, :float
      end
      property :gross_yield do
        key :type, :number
        key :format, :float
      end
      property :isr do
        key :type, :number
        key :format, :float
      end
      property :net_yield do
        key :type, :number
        key :format, :float
      end 
      property :total do
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
      property :investment_id do
        key :type, :string
        key :format, :uuid
      end
      property :funder_id do
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