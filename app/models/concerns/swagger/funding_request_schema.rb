module Swagger::FundingRequestSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :FundingRequestOutput do
      key :required, [:id, :total_requested, :total_investments, :balance, :funding_request_date, :funding_due_date, :status, :project_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :total_requested do
        key :type, :number
        key :format, :float
      end
      property :total_investments do
        key :type, :number
        key :format, :float
      end
      property :balance do
        key :type, :number
        key :format, :float
      end      
      property :funding_request_date do
        key :type, :string
        key :format, :date
      end
      property :funding_due_date do
        key :type, :string
        key :format, :date
      end
      property :status do
        key :type, :string
      end
      property :attached do
        key :type, :string
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