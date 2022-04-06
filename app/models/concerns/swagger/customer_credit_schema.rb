module Swagger::CustomerCreditSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CustomerCreditOutput do
      key :required, [:id, :total_requested, :capital, :interests, :iva, :fixed_payment, :total_debt, :total_payments, :balance, :status, :start_date, :end_date,
                      :rate, :iva_percent, :customer_id, :term_id, :payment_period_id]
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
      property :rate do
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
       property :destination do
        key :type, :string
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
      property :iva_percent do
        key :type, :number
        key :format, :float
      end
      property :attached do
        key :type, :string
      end
      property :customer_id do
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