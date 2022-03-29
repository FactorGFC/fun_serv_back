module Swagger::PostalCodesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    swagger_path '/postal_codes/pc/:pc' do
      parameter name: :pc do
        key :in, :query
        key :description, 'Codigo postal a filtrar'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end

      parameter name: :token do
        key :in, :query
        key :description, 'Token del inicio de la sesión del usuario'
        key :required, true
        key :type, :string
      end

      parameter name: :secret_key do
        key :in, :query
        key :description, 'Llave secreta del javascript origins'
        key :required, true
        key :type, :string
      end
      # GET /postal_codes/
      operation :get do
        key :description, 'Trae todas las colonias filtrando por código postal'
        key :operationId, :find_postal_codes_cp
        key :produces, ['application/json']
        key :tags, [:PostalCode]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PostalCodeOutput
          end
        end
        response 204 do
          key :description, 'Transacción correcta, respuesta sin contenido'
        end
        extend Swagger::ErrorResponses::NotFoundError
        extend Swagger::ErrorResponses::Unauthorized
        extend Swagger::ErrorResponses::UnprocessableEntity
        extend Swagger::ErrorResponses::InternalServerError
      end
    end
  end
end
