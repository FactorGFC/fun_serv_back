module Swagger::CitiesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/states/{state_id}/cities' do
      parameter name: :state_id do
        key :in, :path
        key :description, 'ID del estado. FK: STATES'
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
      # GET /states/:state_id/cities
      operation :get do
        key :description, 'Trae todas las ciudades de un estado'
        key :operationId, :find_state_cities
        key :produces, ['application/json']
        key :tags, [:City]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CityOutput
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

    swagger_path '/states/{state_id}/cities/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :state_id do
        key :in, :path
        key :description, 'ID del estado FK: STATES'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID de la ciudad'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end
 # definición de los parámetros de entrada
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

      # GET /states/{state_id}/cities/{id}
      operation :get do
        key :description, 'Busca una ciudad de un estado'
        key :operationId, :find_city_by_id
        key :produces, ['application/json']
        key :tags, [:City]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CityOutput
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
      # PATCH /states/{state_id}/cities/{id}
      operation :patch do
        key :description, 'Busca una ciudad de un estado y actualiza el dato enviado'
        key :operationId, :update_city_by_id
        key :produces, ['application/json']
        key :tags, [:City]

        parameter name: :name do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CityOutput
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
      # DELETE /states/{state_id}/cities/{id}
      operation :delete do
        key :description, 'Elimina una ciudad de un estado por su ID'
        key :operationId, :delete_city_by_id
        key :produces, ['application/json']
        key :tags, [:City]

        # definición de las respuestas
        response 200 do
          key :description, 'La ciudad fue eliminado'
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

    swagger_path '/states/{state_id}/cities' do

      # POST /states/{state_id}/cities
      operation :post do
        key :description, 'Crea una nueva ciudad para un estado'
        key :operationId, :create_city
        key :produces, ['application/json']
        key :tags, [:City]

        # Traemos los parametros
        parameter name: :state_id do
          key :in, :path
          key :description, 'ID del estado. FK STATES'
          key :required, true
          key :type, :integer
          key :format, :bigint
        end

        parameter name: :name do
          key :in, :query
          key :description, 'Nombre de la ciudad'
          key :required, true
          key :type, :string
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
            key :'$ref', :CityOutput
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