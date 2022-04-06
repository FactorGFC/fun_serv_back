module Swagger::CustomerSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :CustomerOutput do
      key :required, [:id, :customer_type, :name, :status, :salary, :salary_period, :contributor_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :customer_type do
        key :type, :string
      end
      property :name do
        key :type, :string
      end
      property :status do
        key :type, :string
      end
      property :salary do
        key :type, :number
        key :format, :float
      end
      property :salary_period do
        key :type, :string
      end
      property :customer_type do
        key :type, :string
      end
      property :other_income do
        key :type, :number
        key :format, :float
      end
      property :assist_bonus do
        key :type, :number
        key :format, :float
      end
      property :net_expenses do
        key :type, :number
        key :format, :float
      end
      property :family_expenses do
        key :type, :number
        key :format, :float
      end
      property :house_rent do
        key :type, :number
        key :format, :float
      end
      property :credit_cp do
        key :type, :number
        key :format, :float
      end
      property :credit_lp do
        key :type, :number
        key :format, :float
      end
      property :salary do
        key :type, :number
        key :format, :float
      end
      property :attached do
        key :type, :string
      end
      property :immediate_superior do
        key :type, :string
      end
      property :seniority do
        key :type, :number
        key :format, :float
      end
      property :ontime_bonus do
        key :type, :number
        key :format, :float
      end
      property :assist_bonus do
        key :type, :number
        key :format, :float
      end
      property :food_vouchers do
        key :type, :number
        key :format, :float
      end
      property :total_income do
        key :type, :number
        key :format, :float
      end
      property :total_savings_food do
        key :type, :number
        key :format, :float
      end
      property :chrismas_bonus do
        key :type, :number
        key :format, :float
      end
      property :taxes do
        key :type, :number
        key :format, :float
      end
      property :imms do
        key :type, :number
        key :format, :float
      end
      property :savings_found do
        key :type, :number
        key :format, :float
      end
      property :savings_found_loand do
        key :type, :number
        key :format, :float
      end
      property :savings_bank do
        key :type, :number
        key :format, :float
      end
      property :insurance_discount do
        key :type, :number
        key :format, :float
      end
      property :child_support do
        key :type, :number
        key :format, :float
      end
      property :extra_expenses do
        key :type, :number
        key :format, :float
      end
      property :infonavit do
        key :type, :number
        key :format, :float
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
      property :contributor_id do
        key :type, :string
        key :format, :uuid
      end
      property :user_id do
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
