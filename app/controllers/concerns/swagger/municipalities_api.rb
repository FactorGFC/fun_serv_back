module Swagger::MunicipalitiesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/states/{state_id}/municipalities' do
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
      # GET /states/:state_id/municipalities
      operation :get do
        key :description, 'Trae todos los municipios de un estado'
        key :operationId, :find_state_municipalities
        key :produces, ['application/json']
        key :tags, [:Municipality]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :MunicipalityOutput
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

    swagger_path '/states/{state_id}/municipalities/{id}' do
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
        key :description, 'ID del municipio'
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

      # GET /states/{state_id}/municipalities/{id}
      operation :get do
        key :description, 'Busca un municipio de un estado'
        key :operationId, :find_municipality_by_id
        key :produces, ['application/json']
        key :tags, [:Municipality]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :MunicipalityOutput
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
      # PATCH /states/{state_id}/municipalities/{id}
      operation :patch do
        key :description, 'Busca un municipio de un estado y actualiza el dato enviado'
        key :operationId, :update_municipality_by_id
        key :produces, ['application/json']
        key :tags, [:Municipality]

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
            key :'$ref', :MunicipalityOutput
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
      # DELETE /states/{state_id}/municipalities/{id}
      operation :delete do
        key :description, 'Elimina un municipio de un estado por su ID'
        key :operationId, :delete_municipality_by_id
        key :produces, ['application/json']
        key :tags, [:Municipality]

        # definición de las respuestas
        response 200 do
          key :description, 'El municipio fue eliminado'
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

    swagger_path '/states/{state_id}/municipalities' do

      # POST /states/{state_id}/municipalities
      operation :post do
        key :description, 'Crea un nuevo municipio para un estado'
        key :operationId, :create_municipality
        key :produces, ['application/json']
        key :tags, [:Municipality]

        # Traemos los parametros
        parameter name: :state_id do
          key :in, :path
          key :description, 'ID del estado. FK STATES'
          key :required, true
          key :type, :integer
          key :format, :bigint
        end

        parameter name: :municipality_key do
          key :in, :query
          key :description, 'Clave del municipio'
          key :required, true
          key :type, :string
        end
        
        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del municipio'
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
            key :'$ref', :MunicipalityOutput
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