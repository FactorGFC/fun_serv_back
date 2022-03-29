module Swagger::InvestmentSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :InvestmentOutput do
      key :required, [:id, :toal, :rate, :investment_date, :status, :funder_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :total do
        key :type, :number
        key :format, :float
      end
      property :rate do
        key :type, :number
        key :format, :float
      end
      property :investment_date do
        key :type, :string
        key :format, :date
      end
      property :status do
        key :type, :string
      end
      property :attached do
        key :type, :string
      end      
      property :funding_request_id do
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