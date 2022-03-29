module Swagger::DocumentsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/documents' do
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
      # GET /documents/
      operation :get do
        key :description, 'Trae todo los documentos'
        key :operationId, :find_documents
        key :produces, ['application/json']
        key :tags, [:Document]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :DocumentOutput
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

    swagger_path '/documents/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del documento'
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

      # GET /documents/:id
      operation :get do
        key :description, 'Busca un documento por su ID'
        key :operationId, :find_document_by_id
        key :produces, ['application/json']
        key :tags, [:Document]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :DocumentOutput
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
      # PATCH /documents/:id
      operation :patch do
        key :description, 'Busca un documento y actualiza el dato enviado'
        key :operationId, :update_document_by_id
        key :produces, ['application/json']
        key :tags, [:Document]

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
            key :'$ref', :DocumentOutput
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
      # DELETE /documents/:id
      operation :delete do
        key :description, 'Elimina un documento por su ID'
        key :operationId, :delete_document_by_id
        key :produces, ['application/json']
        key :tags, [:Document]

        # definición de las respuestas
        response 200 do
          key :description, 'El documento fue eliminado'
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

    swagger_path '/documents' do

      # POST /documents
      operation :post do
        key :description, 'Crea un nuevo documento'
        key :operationId, :create_document
        key :produces, ['application/json']
        key :tags, [:Document]

        # Traemos los parametros
        parameter name: :document_type do
          key :in, :query
          key :description, 'Tipo de documento, dominio de LV: DOCUMENT.TYPE'
          key :required, true
          key :type, :string
          key :enum, ['ID', 'DM', 'EC', 'AF', 'RN', 'RF', 'AC']
        end

        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del documento'
          key :required, true
          key :type, :string
        end
        
        parameter name: :description do
          key :in, :query
          key :description, 'Descripción del documento'
          key :required, true
          key :type, :string
        end

        parameter name: :validation do
          key :in, :query
          key :description, 'Validación del documento'
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
            key :'$ref', :DocumentOutput
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