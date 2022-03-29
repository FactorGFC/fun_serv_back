module Swagger::ContributorAddressSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ContributorAddressOutput do
      key :required, [:id, :contributor_id, :municipality_id, :state_id, :street, :external_number, :suburb, :postal_code]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :contributor_id do
        key :type, :integer
        key :format, :bigint
      end
      property :municipality_id do
        key :type, :integer
        key :format, :bigint
      end
      property :state_id do
        key :type, :integer
        key :format, :bigint
      end
      property :address_type do
        key :type, :string
      end
      property :street do
        key :type, :string
      end
      property :external_number do
        key :type, :integer
      end
      property :apartment_number do
        key :type, :string
      end
      property :suburb_type do
        key :type, :string
      end
      property :suburb do
        key :type, :string
      end
      property :postal_code do
        key :type, :integer
      end
      property :address_reference do
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
