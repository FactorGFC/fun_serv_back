module Swagger::StatesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/countries/:country_id/states' do
      # definición del parámetro id incluido en el path
      parameter name: :country_id do
        key :in, :query
        key :description, 'ID del del país'
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
      # GET /states/
      operation :get do
        key :description, 'Trae todos los estados de un país'
        key :operationId, :find_country_states
        key :produces, ['application/json']
        key :tags, [:State]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :StateOutput
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

    swagger_path '/countries/:country_id/states/{id}' do
      # definición de los parámetro id incluidos en el path
      parameter name: :country_id do
        key :in, :query
        key :description, 'ID del del país'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del del estado'
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

      # GET /states/:id
      operation :get do
        key :description, 'Busca un estado de un país por su id'
        key :operationId, :find_country_state_by_id
        key :produces, ['application/json']
        key :tags, [:State]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :StateOutput
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
