module Swagger::FileTypesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/file_types' do
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
      # GET /file_types/
      operation :get do
        key :description, 'Trae todos los servicios externos'
        key :operationId, :find_file_types
        key :produces, ['application/json']
        key :tags, [:FileType]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FileTypeOutput
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

    swagger_path '/file_types/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del tipo de expediente'
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

      # GET /file_types/:id
      operation :get do
        key :description, 'Busca un tipo de expediente por su ID'
        key :operationId, :find_file_type_by_id
        key :produces, ['application/json']
        key :tags, [:FileType]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FileTypeOutput
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
      # PATCH /file_types/:id
      operation :patch do
        key :description, 'Busca un tipo de expediente y actualiza el dato enviado'
        key :operationId, :update_file_type_by_id
        key :produces, ['application/json']
        key :tags, [:FileType]

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
            key :'$ref', :FileTypeOutput
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
      # DELETE /file_types/:id
      operation :delete do
        key :description, 'Elimina un tipo de expediente por su ID'
        key :operationId, :delete_file_type_by_id
        key :produces, ['application/json']
        key :tags, [:FileType]

        # definición de las respuestas
        response 200 do
          key :description, 'El tipo de expediente fue eliminado'
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

    swagger_path '/file_types' do

      # POST /file_types
      operation :post do
        key :description, 'Crea un nuevo tipo de expediente'
        key :operationId, :create_file_type
        key :produces, ['application/json']
        key :tags, [:FileType]

        # definición de los parámtros
        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del tipo de expediente'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción del tipo de expediente'
          key :required, true
          key :type, :string
        end

        parameter name: :customer_type do
          key :in, :query
          key :description, 'El tipo de cliente que usará este tipo de expediente'
          key :required, false
          key :type, :string          
        end

        parameter name: :funder_type do
          key :in, :query
          key :description, 'El tipo de fondeador que usará este tipo de expediente'
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
            key :'$ref', :FileTypeOutput
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