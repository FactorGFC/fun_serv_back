module Swagger::FunderSchema
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    swagger_schema :FunderOutput do
      key :required, [:id, :funder_type, :name, :status, :contributor_id, :user_id]
      property :id do
        key :type, :string
        key :format, :uuid
      end
      property :funder_type do
        key :type, :string
      end
      property :name do
        key :type, :string
      end
      property :status do
        key :type, :string
      end
      property :attached do
        key :type, :string
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
