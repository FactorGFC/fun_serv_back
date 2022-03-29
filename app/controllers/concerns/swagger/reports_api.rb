module Swagger::ReportsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema

    swagger_path '/reports/user/{user_id}/not_options' do

      # GET /authenticate
      operation :get do
        key :description, 'Trae todas las opciones que no están asignadas al usurio enviado'
        key :operationId, :report_user_not_option
        key :produces, ['application/json']
        key :tags, [:Report]

        # Traemos los parametros
        parameter name: :user_id do
          key :in, :path
          key :description, 'ID del usurio'
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

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ReportOutput
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

    swagger_path '/reports/role/{role_id}/not_options' do

      # GET /authenticate
      operation :get do
        key :description, 'Trae todas las opciones que no están asignadas al rol enviado'
        key :operationId, :report_role_not_option
        key :produces, ['application/json']
        key :tags, [:Report]

        # Traemos los parametros
        parameter name: :role_id do
          key :in, :path
          key :description, 'ID del rol'
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

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ReportOutput
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
