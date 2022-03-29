module Swagger::ContributorSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :ContributorOutput do
      key :required, [:id, :contributor_type]
      property :id do
        key :type, :integer
        key :format, :bigint
      end
      property :contributor_type do
        key :type, :string
      end
      property :bank do
        key :type, :string
      end
      property :account_number do
        key :type, :integer
        key :format, :bigint
      end
      property :clabe do
        key :type, :integer
        key :format, :bigint
      end
      property :person_id do
        key :type, :integer
        key :format, :bigint
      end
      property :legal_entity_id do
        key :type, :integer
        key :format, :bigint
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