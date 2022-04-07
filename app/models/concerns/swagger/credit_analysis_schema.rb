module Swagger::CreditAnalysisSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CreditAnalysisOutput do
      key :required, [:id, :credit_status, :report_date, :mop_key, :lowest_key, :customer_credit_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
    
      property :departamental_credit do
        key :type, :number
        key :format, :float
      end
      property :car_credit do
        key :type, :number
        key :format, :float
      end
      property :mortagage_loan do
        key :type, :number
        key :format, :float
      end
      property :other_credits do
        key :type, :number
        key :format, :float
      end
      property :accured_liabilities do
        key :type, :number
        key :format, :float
      end
      property :debt do
        key :type, :number
        key :format, :float
      end
      property :net_flow do
        key :type, :number
        key :format, :float
      end
      property :debt_rate do
        key :type, :number
        key :format, :float
      end
      property :cash_flow do
        key :type, :number
        key :format, :float
      end
      property :credit_status do
        key :type, :string
       end
       property :debt_time do
        key :type, :number
        key :format, :float
      end
      property :previus_credit do
        key :type, :string
       end
       property :discounts do
        key :type, :number
        key :format, :float
      end
       property :debt_horizon do
        key :type, :number
        key :format, :float
      end
      property :amount_allowed do
        key :type, :number
        key :format, :float
      end
      property :time_allowed do
        key :type, :number
        key :format, :float
      end
      property :report_date do
        key :type, :string
        key :format, :date
      end
      property :mop_key do
        key :type, :string
       end
       property :last_key do
        key :type, :number
        key :format, :float
      end
      property :lowest_key do
        key :type, :number
        key :format, :float
      end
       property :balance_due do
        key :type, :string
       end
       property :payment_capacity do
        key :type, :number
        key :format, :float
       end
      property :customer_credit_id do
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

