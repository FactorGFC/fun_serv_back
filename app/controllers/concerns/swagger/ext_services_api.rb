module Swagger::ExtServicesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/ext_services' do
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
      # GET /ext_services/
      operation :get do
        key :description, 'Trae todos los servicios externos'
        key :operationId, :find_ext_services
        key :produces, ['application/json']
        key :tags, [:ExtService]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ExtServiceOutput
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

    swagger_path '/ext_services/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del servicio externo'
        key :required, true
        key :type, :string
        key :format, :uuid 
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

      # GET /ext_services/:id
      operation :get do
        key :description, 'Busca un servicio externo por su ID'
        key :operationId, :find_ext_service_by_id
        key :produces, ['application/json']
        key :tags, [:ExtService]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ExtServiceOutput
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
      # PATCH /ext_services/:id
      operation :patch do
        key :description, 'Busca un servicio externo y actualiza el dato enviado'
        key :operationId, :update_ext_service_by_id
        key :produces, ['application/json']
        key :tags, [:ExtService]

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
            key :'$ref', :ExtServiceOutput
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
      # DELETE /ext_services/:id
      operation :delete do
        key :description, 'Elimina un servicio externo por su ID'
        key :operationId, :delete_ext_service_by_id
        key :produces, ['application/json']
        key :tags, [:ExtService]

        # definición de las respuestas
        response 200 do
          key :description, 'El servicio externo fue eliminado'
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

    swagger_path '/ext_services' do

      # POST /ext_services
      operation :post do
        key :description, 'Crea un nuevo servicio externo'
        key :operationId, :create_ext_service
        key :produces, ['application/json']
        key :tags, [:ExtService]

        # definición de los parámtros
        parameter name: :supplier do
          key :in, :query
          key :description, 'Proveedor del servicio externo'
          key :required, true
          key :type, :string
        end

        parameter name: :user do
          key :in, :query
          key :description, 'Usuario del servicio externo'
          key :required, true
          key :type, :string
        end

        parameter name: :api_key do
          key :in, :query
          key :description, 'La llave del servicio externo'
          key :required, false
          key :type, :string          
        end

        parameter name: :token do
          key :in, :query
          key :description, 'El token del servicio externo'
          key :required, false
          key :type, :string          
        end

        parameter name: :url do
          key :in, :query
          key :description, 'Url del servicio externo'
          key :required, true
          key :type, :string
        end

        parameter name: :rule do
          key :in, :query
          key :description, 'Regla de uso'
          key :required, false
          key :type, :string
        end

        parameter name: :itoken do
          key :in, :query
          key :description, 'Token del inicio de la sesión del usuario (es sin la i)'
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
            key :'$ref', :ExtServiceOutput
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