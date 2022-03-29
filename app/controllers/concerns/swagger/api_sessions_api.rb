module Swagger::ApiSessionsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema

    swagger_path '/authenticate' do

      # GET /authenticate
      operation :get do
        key :description, 'Crea una nueva sesión del usuario'
        key :operationId, :authenticate
        key :produces, ['application/json']
        key :tags, [:Authentication]

        # Traemos los parametros
        parameter name: :email do
          key :in, :query
          key :description, 'Correo electrónico del usuario'
          key :required, true
          key :type, :string
          key :format, :email 
        end

        parameter name: :password do
          key :in, :query
          key :description, 'Password del usuario'
          key :required, true
          key :type, :string
          key :format, :password
        end

        parameter name: :secret_key do
          key :in, :query
          key :description, 'Llave secreta del javascript origins'
          key :required, true
          key :type, :string
        end

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ApiSessionOutput
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