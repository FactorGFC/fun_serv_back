module Swagger::OptionsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/options' do
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
      # GET /options/
      operation :get do
        key :description, 'Trae todas las opciones'
        key :operationId, :find_options
        key :produces, ['application/json']
        key :tags, [:Option]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :OptionOutput
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

    swagger_path '/options/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la opción'
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

      # GET /options/:id
      operation :get do
        key :description, 'Busca una opción por su ID'
        key :operationId, :find_option_by_id
        key :produces, ['application/json']
        key :tags, [:Option]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :OptionOutput
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
      # PATCH /options/:id
      operation :patch do
        key :description, 'Busca una opción y actualiza el dato enviado'
        key :operationId, :update_option_by_id
        key :produces, ['application/json']
        key :tags, [:Option]

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
            key :'$ref', :OptionOutput
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
      # DELETE /options/:id
      operation :delete do
        key :description, 'Elimina una opción por su ID'
        key :operationId, :delete_option_by_id
        key :produces, ['application/json']
        key :tags, [:Option]

        # definición de las respuestas
        response 200 do
          key :description, 'La opción fue eliminada'
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

    swagger_path '/options' do

      # POST /options
      operation :post do
        key :description, 'Crea una nueva opción'
        key :operationId, :create_option
        key :produces, ['application/json']
        key :tags, [:Option]

        # definición de los parámtros
        parameter name: :name do
          key :in, :query
          key :description, 'Nombre de la opción'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción de la opción'
          key :required, true
          key :type, :string
        end

        parameter name: :group do
          key :in, :query
          key :description, 'Grupo al que pertenece la opción'
          key :required, false
          key :type, :string
          key :enum, ['CATÁLOGOS', 'CONTRIBUYENTES', 'CADENAS', 'PROOVEDORES', 'FACTURAS', 'SOLICITUDES', 'PAGOS', 'ORDENES DE COMPRA', 'REPORTES', 'CONFIGURACIÓN']
        end

        parameter name: :url do
          key :in, :query
          key :description, 'Url de la opción'
          key :required, false
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
            key :'$ref', :OptionOutput
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